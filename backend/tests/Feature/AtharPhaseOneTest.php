<?php

namespace Tests\Feature;

use App\Models\AidCampaign;
use App\Models\Beneficiary;
use App\Models\EmergencyMission;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\User;
use Illuminate\Support\Str;
use Tests\TestCase;

class AtharPhaseOneTest extends TestCase
{
    private User $volunteer;
    private string $plainToken;

    protected function setUp(): void
    {
        parent::setUp();

        $this->plainToken = 'test_token_' . Str::random(32);
        $this->volunteer = User::where('role', 'volunteer')->where('is_active', true)->first() ?? User::factory()->create([
            'role' => 'volunteer',
            'is_active' => true,
        ]);

        $this->volunteer->api_token = hash('sha256', $this->plainToken);
        $this->volunteer->save();
    }

    private function authHeaders(): array
    {
        return [
            'Authorization' => 'Bearer ' . $this->plainToken,
            'Accept' => 'application/json',
        ];
    }

    public function test_nfc_and_qr_lookup_finds_beneficiary(): void
    {
        $beneficiary = Beneficiary::first();
        $this->assertNotNull($beneficiary, 'Beneficiary must exist in DB');

        // Test NFC UID Lookup
        $response = $this->postJson('/api/beneficiaries/lookup', [
            'token' => $beneficiary->nfc_card_uid,
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $beneficiary->id,
                    'national_id' => $beneficiary->national_id,
                ],
            ]);

        // Test QR Token Lookup
        $responseQr = $this->postJson('/api/beneficiaries/lookup', [
            'token' => $beneficiary->qr_token,
        ], $this->authHeaders());

        $responseQr->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $beneficiary->id,
                ],
            ]);
    }

    public function test_aid_distribution_flow_and_double_dipping_prevention(): void
    {
        $campaign = AidCampaign::where('status', 'active')->first();
        $beneficiary = Beneficiary::whereDoesntHave('distributions', function ($q) use ($campaign) {
            $q->where('campaign_id', $campaign->id);
        })->first();

        if (!$beneficiary) {
            $gov = Governorate::first();
            $beneficiary = Beneficiary::create([
                'full_name' => 'عائلة اختبارية للتوزيع',
                'national_id' => '999' . rand(10000000, 99999999),
                'phone' => '+963 999 123 456',
                'governorate_id' => $gov ? $gov->id : 1,
                'district' => 'الميدان',
                'family_members_count' => 4,
                'vulnerability_score' => 85,
                'nfc_card_uid' => 'ATHAR-TEST-' . rand(1000, 9999),
                'qr_token' => 'QR-TEST-' . rand(1000, 9999),
                'status' => 'active',
            ]);
        }

        $this->assertNotNull($campaign, 'Active campaign must exist');
        $this->assertNotNull($beneficiary, 'Undistributed beneficiary must exist');

        $initialPoints = $this->volunteer->volunteer_points ?? 0;
        $initialDistributed = $campaign->distributed_families_count;

        // 1. First distribution: must SUCCEED
        $response = $this->postJson('/api/distributions/verify-and-deliver', [
            'campaign_id' => $campaign->id,
            'token' => $beneficiary->nfc_card_uid,
            'verification_method' => 'nfc_tap',
            'latitude' => 33.5130,
            'longitude' => 36.2950,
            'notes' => 'تسليم سلة غذائية - كشف أول',
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->volunteer->refresh();
        $campaign->refresh();

        $this->assertEquals($initialPoints + 15, $this->volunteer->volunteer_points);
        $this->assertEquals($initialDistributed + 1, $campaign->distributed_families_count);

        // 2. Second distribution attempt to SAME family in SAME campaign: MUST BE REJECTED (422)
        $secondAttempt = $this->postJson('/api/distributions/verify-and-deliver', [
            'campaign_id' => $campaign->id,
            'token' => $beneficiary->nfc_card_uid,
            'verification_method' => 'nfc_tap',
        ], $this->authHeaders());

        $secondAttempt->assertStatus(422)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_field_assessment_submission(): void
    {
        $beneficiary = Beneficiary::first();

        $response = $this->postJson('/api/field-assessments', [
            'beneficiary_id' => $beneficiary->id,
            'living_condition_score' => 7,
            'housing_type' => 'إيجار',
            'heating_available' => false,
            'monthly_income_estimate' => 650000,
            'income_source' => 'عمل يومي متقطع',
            'urgency_rating' => 'high',
            'inspector_notes' => 'المنزل رطب ويفتقر لوسائل التدفئة، العائلة بحاجة فورية لبطانيات وسلة غذائية.',
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'living_condition_score' => 7,
                    'status' => 'submitted',
                ],
            ]);
    }

    public function test_emergency_mission_join_and_check_in(): void
    {
        $mission = EmergencyMission::where('status', 'open')->first();
        $this->assertNotNull($mission, 'Open emergency mission must exist');
        $mission->volunteers()->detach($this->volunteer->id);
        $mission->update(['volunteers_joined' => 0, 'volunteers_needed' => 10]);

        // Join Mission
        $joinResponse = $this->postJson("/api/emergency-missions/{$mission->id}/join", [], $this->authHeaders());
        $joinResponse->assertStatus(200)
            ->assertJson(['success' => true]);

        // Check In on-site
        $checkInResponse = $this->postJson("/api/emergency-missions/{$mission->id}/check-in", [], $this->authHeaders());
        $checkInResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'checked_in',
                ],
            ]);
    }

    public function test_volunteer_passport_and_public_certificate(): void
    {
        // 1. Authenticated Passport
        $passportResponse = $this->getJson('/api/volunteer/passport/me', $this->authHeaders());
        $passportResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $this->volunteer->id,
                ],
            ]);

        // 2. Public Certificate Verification (No token required, scanned via QR)
        $publicResponse = $this->getJson("/api/volunteer/passport/verify/{$this->volunteer->id}");
        $publicResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'verified' => true,
                    'volunteer_name' => $this->volunteer->name,
                ],
            ]);
    }

    public function test_inventory_management(): void
    {
        $item = InventoryItem::first();
        $this->assertNotNull($item, 'Inventory item must exist');

        $initialStock = $item->available_stock;

        $response = $this->postJson("/api/inventory/{$item->id}/add-stock", [
            'quantity' => 25,
            'notes' => 'توريد تبرع جديد من شركاء أثر',
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'available_stock' => $initialStock + 25,
                ],
            ]);
    }
}
