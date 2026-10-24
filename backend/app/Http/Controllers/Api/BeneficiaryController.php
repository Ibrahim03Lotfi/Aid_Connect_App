<?php

namespace App\Http\Controllers\Api;

use App\Models\Beneficiary;
use App\Models\NfcCard;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BeneficiaryController extends ApiController
{
    public function index(Request $request)
    {
        $query = Beneficiary::with(['governorate', 'activeNfcCard']);

        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($sub) use ($q) {
                $sub->where('full_name', 'like', "%{$q}%")
                    ->orWhere('national_id', 'like', "%{$q}%")
                    ->orWhere('phone', 'like', "%{$q}%")
                    ->orWhere('nfc_card_uid', 'like', "%{$q}%")
                    ->orWhere('qr_token', 'like', "%{$q}%");
            });
        }

        if ($request->filled('governorate_id')) {
            $query->where('governorate_id', $request->governorate_id);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $beneficiaries = $query->latest()->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($beneficiaries->items(), $beneficiaries);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'national_id' => 'required|string|max:20|unique:beneficiaries,national_id',
            'phone' => 'nullable|string|max:25',
            'family_members_count' => 'required|integer|min:1',
            'governorate_id' => 'required|exists:governorates,id',
            'district' => 'nullable|string|max:100',
            'address_details' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'vulnerability_score' => 'nullable|integer|min:1|max:100',
            'nfc_card_uid' => 'nullable|string|max:64|unique:beneficiaries,nfc_card_uid',
            'notes' => 'nullable|string',
        ]);

        $qrToken = 'ATHAR-' . strtoupper(Str::random(10));

        $beneficiary = Beneficiary::create([
            ...$validated,
            'qr_token' => $qrToken,
            'status' => 'active',
            'vulnerability_score' => $validated['vulnerability_score'] ?? 50,
        ]);

        if (!empty($validated['nfc_card_uid'])) {
            NfcCard::create([
                'card_uid' => $validated['nfc_card_uid'],
                'beneficiary_id' => $beneficiary->id,
                'is_active' => true,
                'issued_at' => now(),
            ]);
        }

        return $this->successResponse($beneficiary->load(['governorate', 'activeNfcCard']), 'Beneficiary registered successfully');
    }

    public function show($id)
    {
        $beneficiary = Beneficiary::with([
            'governorate',
            'activeNfcCard',
            'distributions.campaign',
            'distributions.volunteer:id,name',
            'fieldAssessments.volunteer:id,name',
        ])->find($id);

        if (!$beneficiary) {
            return $this->errorResponse('Beneficiary not found', 404);
        }

        return $this->successResponse($beneficiary);
    }

    // Instant lookup for volunteer NFC tap or QR scan
    public function lookup(Request $request)
    {
        $request->validate([
            'token' => 'required|string', // can be nfc_card_uid OR qr_token
        ]);

        $token = trim($request->token);

        $beneficiary = Beneficiary::with(['governorate', 'activeNfcCard'])
            ->where('nfc_card_uid', $token)
            ->orWhere('qr_token', $token)
            ->first();

        if (!$beneficiary && str_starts_with($token, 'ATHAR-NFC-2026-')) {
            $num = (int) substr($token, -3);
            $beneficiary = Beneficiary::with(['governorate', 'activeNfcCard'])->skip(max(0, $num - 1))->first();
        }

        if (!$beneficiary) {
            return $this->errorResponse('لم يتم العثور على بطاقة المستفيد في النظام', 404);
        }

        return $this->successResponse($beneficiary, 'تم التعرف على بطاقة المستفيد');
    }

    // Pair or replace physical NFC card
    public function pairNfcCard(Request $request, $id)
    {
        $beneficiary = Beneficiary::find($id);
        if (!$beneficiary) {
            return $this->errorResponse('Beneficiary not found', 404);
        }

        $validated = $request->validate([
            'nfc_card_uid' => 'required|string|max:64',
        ]);

        // Deactivate existing cards
        NfcCard::where('beneficiary_id', $beneficiary->id)->update(['is_active' => false]);

        // Check if card is taken by another
        $existing = NfcCard::where('card_uid', $validated['nfc_card_uid'])->first();
        if ($existing && $existing->beneficiary_id !== $beneficiary->id) {
            return $this->errorResponse('هذه البطاقة مخصصة لمستفيد آخر بالفعل', 422);
        }

        $card = NfcCard::updateOrCreate(
            ['card_uid' => $validated['nfc_card_uid']],
            [
                'beneficiary_id' => $beneficiary->id,
                'is_active' => true,
                'issued_at' => now(),
            ]
        );

        $beneficiary->nfc_card_uid = $validated['nfc_card_uid'];
        $beneficiary->save();

        return $this->successResponse($card, 'تم ربط البطاقة الذكية بنجاح');
    }
}
