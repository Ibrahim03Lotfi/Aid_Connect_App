<?php

namespace Tests\Feature;

use App\Models\AidCase;
use App\Models\EmergencyMission;
use App\Models\Governorate;
use App\Models\User;
use App\Services\Ai\ImageFingerprintService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Tests\TestCase;

class AtharPhaseFourAiTest extends TestCase
{
    private User $volunteer;
    private string $plainToken;

    protected function setUp(): void
    {
        parent::setUp();

        $this->plainToken = 'test_ai_token_' . Str::random(32);
        $this->volunteer = User::where('role', 'volunteer')->first() ?? User::factory()->create([
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

    /**
     * 1. Test Multimodal Printed Medical Invoice Auditor & Mathematical Integrity.
     */
    public function test_ai_document_auditor_extracts_and_verifies_medical_invoice_math(): void
    {
        $fakeInvoice = UploadedFile::fake()->create('hospital_bill_cardio.jpg', 200, 'image/jpeg');

        $response = $this->postJson('/api/ai/audit-invoice', [
            'document' => $fakeInvoice,
            'context_hint' => 'عملية جراحة قلب مفتوح وتبديل صمام',
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'audited',
                    'is_math_valid' => true,
                    'currency' => 'SYP',
                ],
            ]);

        $data = $response->json('data');
        $this->assertNotEmpty($data['hospital_name']);
        $this->assertNotEmpty($data['patient_diagnosis']);
        $this->assertGreaterThan(0, $data['total_amount']);
        $this->assertEquals($data['total_amount'], $data['calculated_sum'], 'Math integrity must match total with line items sum');
    }

    /**
     * 2. Test Shelter & Living Condition Visual Severity Analyzer.
     */
    public function test_ai_shelter_visual_severity_analyzer(): void
    {
        $photo1 = UploadedFile::fake()->create('damp_wall.jpg', 150, 'image/jpeg');
        $photo2 = UploadedFile::fake()->create('tent_leak.jpg', 150, 'image/jpeg');

        $response = $this->postJson('/api/ai/analyze-shelter', [
            'photos' => [$photo1, $photo2],
            'living_condition_score' => 2,
            'housing_type' => 'خيمة / مأوى مؤقت',
            'heating_available' => false,
            'inspector_notes' => 'تسرب مياه الأمطار من السقف وتشكل برك رطوبة مع نوافذ مكسورة وغياب كامل للتدفئة',
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'structural_severity' => 'critical',
                    'analyzed_photos_count' => 2,
                ],
            ]);

        $data = $response->json('data');
        $this->assertGreaterThanOrEqual(75, $data['damage_score']);
        $this->assertNotEmpty($data['detected_hazards']);
        $this->assertNotEmpty($data['recommended_interventions']);
    }

    /**
     * 3. Test Arabic NLP Urgency & Triage Classifier with 90+ Score for Critical Cases.
     */
    public function test_ai_arabic_nlp_triage_classifier_critical_score(): void
    {
        $title = 'استغاثة عاجلة: رضيع حديث ولادة بحاجة عملية جراحية عاجلة للقلب في مشفى المواساة';
        $description = 'الطفل الرضيع يعاني من تشوه قلبي خلقي ونقص أكسجة حاد مع تجمّد وبرد قارس في خيمة النزوح دون تدفئة أو معيل، وحالته مهددة بالموت السريع خلال 24 ساعة.';

        $response = $this->postJson('/api/ai/triage', [
            'title' => $title,
            'description' => $description,
            'target_amount' => 25000000,
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'triage_tier' => 'critical',
                    'priority_alert' => true,
                ],
            ]);

        $data = $response->json('data');
        $this->assertGreaterThanOrEqual(90, $data['urgency_index'], 'Critical emergency text must score 90+');
        $this->assertNotEmpty($data['key_vulnerability_factors']);
    }

    /**
     * 4. Test Perceptual Image Fingerprinting (dHash) & Duplicate Fraud Detection.
     */
    public function test_ai_perceptual_image_fingerprint_and_fraud_detection(): void
    {
        $fingerprintService = app(ImageFingerprintService::class);

        $case = AidCase::first();
        $this->assertNotNull($case, 'AidCase must exist in DB');

        // Create a fake test image and register its fingerprint
        $testImage = UploadedFile::fake()->create('medical_report_original.jpg', 180, 'image/jpeg');
        $fingerprint = $fingerprintService->computeFingerprint($testImage);

        $fingerprintService->storeFingerprint($case->id, '/storage/cases/medical_report_original.jpg', $fingerprint);

        // Check the exact same image for fraud
        $response = $this->postJson('/api/ai/check-fraud', [
            'image' => $testImage,
            'case_id' => 99999, // checking from a different case
        ], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'is_duplicate' => true,
                    'duplicate_case_id' => $case->id,
                    'flag' => 'suspicious_duplicate_image',
                ],
            ]);

        $this->assertGreaterThanOrEqual(90.0, $response->json('data.similarity_percentage'));
    }

    /**
     * 5. Test Intelligent Volunteer Matchmaker Recommending Top 5 Candidates.
     */
    public function test_ai_volunteer_matchmaker_recommends_top_5(): void
    {
        $gov = Governorate::first();
        $this->assertNotNull($gov, 'Governorate must exist in DB');

        // Ensure we have a few volunteers with skills
        User::factory()->count(6)->create([
            'role' => 'volunteer',
            'is_active' => true,
            'skills' => ['إسعاف أولي', 'تمريض', 'قيادة'],
            'volunteer_hours' => 65.5,
            'volunteer_points' => 320,
            'has_vehicle' => true,
            'governorate_id' => $gov->id,
        ]);

        $mission = EmergencyMission::create([
            'title' => 'قافلة طبية وإسعافية طارئة - ريف دمشق',
            'description' => 'تأمين كوادر تمريض وإسعاف ميداني فوري لمصابي حريق',
            'urgency' => 'critical',
            'required_skills' => ['إسعاف أولي', 'تمريض'],
            'governorate_id' => $gov->id,
            'district' => 'دوما',
            'latitude' => 33.5700,
            'longitude' => 36.4000,
            'volunteers_needed' => 4,
            'volunteers_joined' => 0,
            'status' => 'open',
            'created_by' => $this->volunteer->id,
        ]);

        $response = $this->getJson("/api/ai/match-volunteers/{$mission->id}", $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'mission_id' => $mission->id,
                ],
            ]);

        $volunteers = $response->json('data.recommended_volunteers');
        $this->assertIsArray($volunteers);
        $this->assertLessThanOrEqual(5, count($volunteers));
        $this->assertGreaterThan(0, count($volunteers));

        // Verify sorted descending by match score
        $firstScore = $volunteers[0]['match_score'];
        $lastScore = end($volunteers)['match_score'];
        $this->assertGreaterThanOrEqual($lastScore, $firstScore);
        $this->assertNotEmpty($volunteers[0]['recommendation_reason']);
    }

    /**
     * 6. Test Full Case AI Comprehensive Audit Enriches Case Model.
     */
    public function test_full_case_ai_audit_updates_case_metadata(): void
    {
        $case = AidCase::first();
        $this->assertNotNull($case, 'AidCase must exist in DB');

        $response = $this->postJson("/api/ai/cases/{$case->id}/audit", [], $this->authHeaders());

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'case_id' => $case->id,
                ],
            ]);

        $case->refresh();
        $this->assertNotNull($case->ai_urgency_index, 'Case ai_urgency_index should be populated');
        $this->assertNotNull($case->ai_triage_tier, 'Case ai_triage_tier should be populated');
        $this->assertIsArray($case->ai_vulnerability_factors);
    }
}
