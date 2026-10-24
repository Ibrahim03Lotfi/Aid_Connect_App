<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Models\VolunteerLog;
use Illuminate\Http\Request;

class VolunteerPassportController extends ApiController
{
    // Full passport details for volunteer profile
    public function myPassport(Request $request)
    {
        $volunteer = $request->user();

        $logs = VolunteerLog::where('volunteer_id', $volunteer->id)
            ->latest()
            ->take(15)
            ->get();

        $missionsCount = VolunteerLog::where('volunteer_id', $volunteer->id)->count();
        $familiesHelped = VolunteerLog::where('volunteer_id', $volunteer->id)
            ->where('mission_type', 'aid_distribution')
            ->count();

        // Calculate dynamic rank based on points
        $points = $volunteer->volunteer_points ?? 0;
        $rank = 'متطوع ميداني';
        if ($points >= 500) {
            $rank = 'قائد فريق ميداني';
        } elseif ($points >= 250) {
            $rank = 'مسعف إغاثي أول';
        } elseif ($points >= 100) {
            $rank = 'متطوع نشط';
        }

        return $this->successResponse([
            'id' => $volunteer->id,
            'name' => $volunteer->name,
            'email' => $volunteer->email,
            'phone' => $volunteer->phone,
            'avatar' => $volunteer->avatar,
            'rank' => $rank,
            'points' => $points,
            'hours' => $volunteer->volunteer_hours ?? 0,
            'missions_count' => $missionsCount,
            'families_helped' => $familiesHelped,
            'badges' => [
                ['id' => 'first_aid', 'title' => 'المستجيب السريع', 'unlocked' => $points >= 50, 'icon' => 'ambulance'],
                ['id' => 'century', 'title' => 'نادي المئة ساعة', 'unlocked' => ($volunteer->volunteer_hours ?? 0) >= 100, 'icon' => 'clock'],
                ['id' => 'hero', 'title' => 'نجم العطاء الميداني', 'unlocked' => $familiesHelped >= 25, 'icon' => 'award'],
                ['id' => 'nfc_master', 'title' => 'موثق البطاقات الذكية', 'unlocked' => $familiesHelped >= 10, 'icon' => 'nfc'],
            ],
            'recent_logs' => $logs,
            'certificate_verification_url' => url("/api/volunteer/passport/verify/{$volunteer->id}"),
        ]);
    }

    // Public verification endpoint (when someone scans the QR code on the printed certificate)
    public function verifyCertificate(Request $request, $id)
    {
        $volunteer = User::where('role', 'volunteer')->find($id);

        if (!$volunteer) {
            if ($request->wantsJson()) {
                return $this->errorResponse('شهادة غير صالحة أو غير مسجلة في سجلات منظمة أثر', 404);
            }
            abort(404, 'شهادة غير صالحة أو غير مسجلة في سجلات منظمة أثر');
        }

        $points = $volunteer->volunteer_points ?? 0;
        $rank = 'متطوع ميداني';
        if ($points >= 500) {
            $rank = 'قائد فريق ميداني';
        } elseif ($points >= 250) {
            $rank = 'مسعف إغاثي أول';
        } elseif ($points >= 100) {
            $rank = 'متطوع نشط';
        }

        if (!$request->wantsJson() && !str_contains($request->header('Accept', ''), 'application/json')) {
            return view('dashboard.certificate_verify', compact('volunteer', 'rank'));
        }

        return $this->successResponse([
            'verified' => true,
            'organization' => 'منظمة أثر للإغاثة والتنمية (Athar Relief Foundation)',
            'volunteer_name' => $volunteer->name,
            'joined_since' => $volunteer->created_at->format('Y-m-d'),
            'total_verified_hours' => $volunteer->volunteer_hours ?? 0,
            'total_points' => $volunteer->volunteer_points ?? 0,
            'rank' => $rank,
            'status' => 'شهادة تطوع رقمية معتمدة وموثقة رسمياً',
            'issued_at' => now()->toIso8601String(),
        ], 'تم التحقق من صحة السجل التطوعي بنجاح');
    }
}
