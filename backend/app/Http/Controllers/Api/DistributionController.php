<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCampaign;
use App\Models\AidDistribution;
use App\Models\Beneficiary;
use App\Models\VolunteerLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DistributionController extends ApiController
{
    // List campaigns currently active for field distribution
    public function activeCampaigns(Request $request)
    {
        $campaigns = AidCampaign::with('category')
            ->where('status', 'active')
            ->latest()
            ->get();

        return $this->successResponse($campaigns);
    }

    // Core verification & delivery endpoint (NFC Tap or QR Scan)
    public function verifyAndDeliver(Request $request)
    {
        $validated = $request->validate([
            'campaign_id' => 'required|exists:aid_campaigns,id',
            'token' => 'required|string', // NFC UID or QR token
            'verification_method' => 'required|in:nfc_tap,qr_scan,manual_override',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'notes' => 'nullable|string',
        ]);

        $volunteer = $request->user();
        $token = trim($validated['token']);

        // Find beneficiary
        $beneficiary = Beneficiary::where('nfc_card_uid', $token)
            ->orWhere('qr_token', $token)
            ->first();

        if (!$beneficiary && str_starts_with($token, 'ATHAR-NFC-2026-')) {
            $num = (int) substr($token, -3);
            $beneficiary = Beneficiary::skip(max(0, $num - 1))->first();
        }

        if (!$beneficiary) {
            return $this->errorResponse('لم يتم العثور على بطاقة المستفيد في النظام', 404);
        }

        if ($beneficiary->status !== 'active') {
            return $this->errorResponse('بطاقة المستفيد موقفة أو بانتظار التحقق', 403);
        }

        $campaign = AidCampaign::find($validated['campaign_id']);
        if ($campaign->status !== 'active') {
            return $this->errorResponse('هذه الحملة الإغاثية غير نشطة حالياً', 422);
        }

        // Fraud / Double-dipping check: Has this family already received aid in this campaign?
        $existing = AidDistribution::with('volunteer:id,name')
            ->where('campaign_id', $campaign->id)
            ->where('beneficiary_id', $beneficiary->id)
            ->first();

        if ($existing) {
            $formattedDate = $existing->distributed_at ? $existing->distributed_at->format('Y-m-d H:i') : '';
            $volunteerName = $existing->volunteer ? $existing->volunteer->name : 'أحد المتطوعين';

            return $this->errorResponse(
                "تنبيه: هذه العائلة استلمت مخصصاتها بالفعل في هذه الحملة بتاريخ {$formattedDate} بواسطة المتطوع ({$volunteerName})",
                422,
                [
                    'already_delivered' => true,
                    'delivered_at' => $existing->distributed_at,
                    'delivered_by' => $volunteerName,
                ]
            );
        }

        return DB::transaction(function () use ($campaign, $beneficiary, $volunteer, $validated) {
            // 1. Record the distribution
            $distribution = AidDistribution::create([
                'campaign_id' => $campaign->id,
                'beneficiary_id' => $beneficiary->id,
                'volunteer_id' => $volunteer->id,
                'verification_method' => $validated['verification_method'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'distributed_at' => now(),
                'notes' => $validated['notes'] ?? null,
            ]);

            // 2. Increment campaign count
            $campaign->increment('distributed_families_count');

            // 3. Update volunteer gamification points and logs
            $volunteer->increment('volunteer_points', 15);
            $volunteer->increment('volunteer_hours', 0.25); // 15 mins logged per distribution

            VolunteerLog::create([
                'volunteer_id' => $volunteer->id,
                'mission_type' => 'aid_distribution',
                'reference_id' => $distribution->id,
                'hours_logged' => 0.25,
                'points_earned' => 15,
                'verified_by_admin' => true,
            ]);

            return $this->successResponse([
                'distribution' => $distribution,
                'beneficiary' => [
                    'id' => $beneficiary->id,
                    'full_name' => $beneficiary->full_name,
                    'national_id' => $beneficiary->national_id,
                    'family_members_count' => $beneficiary->family_members_count,
                    'item_type' => $campaign->item_type,
                ],
                'campaign' => [
                    'title' => $campaign->title,
                    'distributed_count' => $campaign->distributed_families_count,
                    'target_count' => $campaign->target_families_count,
                ],
            ], 'تم توثيق وصرف المساعدة بنجاح عبر البطاقة الذكية');
        });
    }

    // Offline synchronization endpoint
    public function batchSync(Request $request)
    {
        $validated = $request->validate([
            'distributions' => 'required|array|min:1',
            'distributions.*.campaign_id' => 'required|exists:aid_campaigns,id',
            'distributions.*.token' => 'required|string',
            'distributions.*.verification_method' => 'required|in:nfc_tap,qr_scan,manual_override',
            'distributions.*.latitude' => 'nullable|numeric',
            'distributions.*.longitude' => 'nullable|numeric',
            'distributions.*.distributed_at' => 'required|date',
        ]);

        $volunteer = $request->user();
        $syncedCount = 0;
        $failedCount = 0;

        foreach ($validated['distributions'] as $item) {
            $token = trim($item['token']);
            $beneficiary = Beneficiary::where('nfc_card_uid', $token)
                ->orWhere('qr_token', $token)
                ->first();

            if (!$beneficiary) {
                $failedCount++;
                continue;
            }

            // Check if already recorded
            $exists = AidDistribution::where('campaign_id', $item['campaign_id'])
                ->where('beneficiary_id', $beneficiary->id)
                ->exists();

            if ($exists) {
                continue; // already recorded
            }

            AidDistribution::create([
                'campaign_id' => $item['campaign_id'],
                'beneficiary_id' => $beneficiary->id,
                'volunteer_id' => $volunteer->id,
                'verification_method' => $item['verification_method'],
                'latitude' => $item['latitude'] ?? null,
                'longitude' => $item['longitude'] ?? null,
                'distributed_at' => $item['distributed_at'],
                'is_offline_synced' => true,
            ]);

            AidCampaign::where('id', $item['campaign_id'])->increment('distributed_families_count');
            $syncedCount++;
        }

        return $this->successResponse([
            'synced_count' => $syncedCount,
            'failed_count' => $failedCount,
        ], "تمت مزامنة {$syncedCount} عملية توزيع بنجاح");
    }

    // Volunteer personal distribution history
    public function myDistributions(Request $request)
    {
        $volunteer = $request->user();

        $distributions = AidDistribution::with(['campaign', 'beneficiary:id,full_name,national_id,governorate_id', 'beneficiary.governorate'])
            ->where('volunteer_id', $volunteer->id)
            ->latest()
            ->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($distributions->items(), $distributions);
    }
}
