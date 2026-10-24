<?php

namespace Tests\Feature;

use App\Models\AidCampaign;
use App\Models\AidCase;
use App\Models\AidDistribution;
use App\Models\Beneficiary;
use App\Models\Category;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\NfcCard;
use App\Models\User;
use App\Services\Ai\ArabicTriageClassifierService;
use App\Services\Ai\DocumentAuditorService;
use App\Services\Ai\ImageFingerprintService;
use Illuminate\Support\Str;
use Tests\TestCase;

class AtharPhaseSixGraduationDefenseTest extends TestCase
{
    protected Governorate $damascus;
    protected Category $healthCategory;
    protected Category $foodCategory;
    protected User $volunteer;
    protected string $plainToken;
    protected Beneficiary $beneficiary;
    protected AidCampaign $campaign;
    protected InventoryItem $inventoryItem;

    protected function setUp(): void
    {
        parent::setUp();

        $this->damascus = Governorate::firstOrCreate(['name' => 'دمشق']);
        $this->healthCategory = Category::firstOrCreate(['name' => 'رعاية صحية']);
        $this->foodCategory = Category::firstOrCreate(['name' => 'سلة غذائية']);

        $this->plainToken = 'test_token_' . Str::random(32);
        $this->volunteer = User::firstOrCreate(
            ['phone' => '0933998877'],
            [
                'name' => 'إبراهيم لطفي (المتطوع الميداني)',
                'email' => 'ibrahim.volunteer' . uniqid() . '@athar-syria.org',
                'password' => bcrypt('password123'),
                'role' => 'volunteer',
                'volunteer_hours' => 54.0,
                'volunteer_points' => 380,
                'vehicle_type' => 'سيارة ميدانية',
                'governorate' => 'دمشق',
            ]
        );

        $this->volunteer->api_token = hash('sha256', $this->plainToken);
        $this->volunteer->save();

        $this->beneficiary = Beneficiary::firstOrCreate(
            ['national_id' => '01019988771'],
            [
                'full_name' => 'يحيى مروان النحاس',
                'phone' => '0944332211',
                'family_members_count' => 5,
                'governorate_id' => $this->damascus->id,
                'district' => 'الميدان',
                'address_details' => 'حي الميدان، قرب جامع الدقاق',
                'vulnerability_score' => 88,
                'nfc_card_uid' => '04:DEF:01:23:45:67',
                'qr_token' => 'ATHAR-QR-DEF01',
                'status' => 'active',
            ]
        );

        NfcCard::firstOrCreate(
            ['card_uid' => '04:DEF:01:23:45:67'],
            [
                'beneficiary_id' => $this->beneficiary->id,
                'is_active' => true,
                'issued_at' => now(),
            ]
        );

        $this->campaign = AidCampaign::firstOrCreate(
            ['title' => 'حملة الدفاع التخرجية 2026 للإغاثة الشاملة'],
            [
                'category_id' => $this->foodCategory->id,
                'start_date' => now()->subDays(2),
                'end_date' => now()->addDays(20),
                'status' => 'active',
                'item_type' => 'سلة غذائية وطبية متكاملة',
                'items_allocated_per_family' => 1,
                'target_families_count' => 100,
                'distributed_families_count' => 10,
            ]
        );

        $this->inventoryItem = InventoryItem::firstOrCreate(
            ['code' => 'DEFENSE-KIT-01'],
            [
                'name' => 'طرد الإغاثة التخرجي المتكامل',
                'category_id' => $this->foodCategory->id,
                'unit' => 'طرد',
                'total_stock' => 100,
                'available_stock' => 90,
                'reserved_stock' => 10,
                'minimum_threshold' => 15,
                'warehouse_location' => 'مستودع الميدان المركزي',
            ]
        );
    }

    private function authHeaders(): array
    {
        return [
            'Authorization' => 'Bearer ' . $this->plainToken,
            'Accept' => 'application/json',
        ];
    }

    /**
     * Stage 1: Web Dashboard & Live GIS Operations Map
     */
    public function test_stage_1_web_dashboard_and_live_gis_operations_map(): void
    {
        // 1. Dashboard metrics render
        $dashboard = $this->get('/dashboard');
        $dashboard->assertStatus(200);
        $dashboard->assertSee('غرفة العمليات المركزية');
        $dashboard->assertSee('العائلات المستفيدة هذا الشهر');

        // 2. GIS live map and data API
        $gisData = $this->getJson('/dashboard/api/gis-data');
        $gisData->assertStatus(200);
        $gisData->assertJsonStructure(['cases', 'volunteers', 'warehouses']);
    }

    /**
     * Stage 2 & 3: Citizen Aid Request + AI Multimodal Auditor & Triage Engine
     */
    public function test_stage_2_and_3_citizen_request_with_ai_audit_and_triage(): void
    {
        // Citizen submits aid request
        $case = AidCase::create([
            'title' => 'عملية جراحية عاجلة لقلب مفتوح وإنعاش لطفل رضيع',
            'description' => 'الطفل عمره سنة ونصف يعاني من رتق رئوي وتشوه خلقي معقد، بحاجة جراحة قلب مفتوح فورية في مشفى المواساة بدمشق.',
            'governorate_id' => $this->damascus->id,
            'category_id' => $this->healthCategory->id,
            'status' => 'pending',
            'priority' => 'urgent',
            'target_amount' => 25000000,
            'collected_amount' => 0,
        ]);

        $this->assertNotNull($case->id);

        // AI 1: Arabic NLP Triage Classifier
        $triageService = new ArabicTriageClassifierService();
        $triageResult = $triageService->classifyCase($case->title, $case->description, ['family_members' => 5]);

        $this->assertGreaterThanOrEqual(70, $triageResult['urgency_index']);
        $this->assertNotEmpty($triageResult['key_vulnerability_factors']);

        // AI 2: Medical Document Auditor
        $auditor = new DocumentAuditorService();
        $invoiceAudit = $auditor->auditDocument('invoice_cardio_surgery.pdf', 'عملية جراحة قلب مفتوح وتبديل صمام');

        $this->assertTrue($invoiceAudit['is_math_valid']);
        $this->assertEquals(25000000, $invoiceAudit['total_amount']);

        // AI 3: Image Fingerprint dHash & Fraud check
        $fingerprinter = new ImageFingerprintService();
        $dhashHex = $fingerprinter->computeFingerprint('case-invoice-' . $case->id);
        $this->assertEquals(16, strlen($dhashHex));
        $fraudCheck = $fingerprinter->checkFraud('case-invoice-' . $case->id, $case->id);
        $this->assertFalse($fraudCheck['is_duplicate']);

        // Update case with audited AI metrics
        $case->update([
            'ai_urgency_index' => $triageResult['urgency_index'],
            'ai_triage_tier' => $triageResult['triage_tier'],
            'ai_vulnerability_factors' => $triageResult['key_vulnerability_factors'],
            'ai_fraud_status' => 'verified_authentic',
        ]);

        $freshCase = $case->fresh();
        $this->assertEquals('verified_authentic', $freshCase->ai_fraud_status);
        $this->assertGreaterThanOrEqual(70, $freshCase->ai_urgency_index);
    }

    /**
     * Stage 4: Volunteer accepts case & conducts Field Assessment
     */
    public function test_stage_4_volunteer_accepts_case_and_submits_field_assessment(): void
    {
        $case = AidCase::create([
            'title' => 'كشف ميداني لمنزل متضرر في ريف دمشق',
            'description' => 'تشققات في الجدران مع تسرب مياه الأمطار',
            'governorate_id' => $this->damascus->id,
            'category_id' => $this->healthCategory->id,
            'status' => 'pending',
            'priority' => 'urgent',
        ]);

        // Admin assigns volunteer on Dashboard
        $assignResponse = $this->post("/dashboard/cases/{$case->id}/assign", [
            'volunteer_id' => $this->volunteer->id,
            'notes' => 'يرجى توثيق أضرار السقف والتحقق من دخل الأسرة',
        ]);
        $assignResponse->assertRedirect();
        $this->assertEquals('assigned_for_inspection', $case->fresh()->status);

        // Volunteer submits assessment via Mobile API with auth token
        $assessmentResponse = $this->postJson('/api/field-assessments', [
            'case_id' => $case->id,
            'living_condition_score' => 3, // 1-10
            'housing_type' => 'منزل متضرر بشدة',
            'heating_available' => false,
            'monthly_income_estimate' => 450000,
            'urgency_rating' => 'critical',
            'inspector_notes' => 'المنزل غير مؤهل للسكن الشتوي، رطوبة شديدة وتصدع في السقف.',
        ], $this->authHeaders());

        $assessmentResponse->assertStatus(200);
        $assessmentResponse->assertJson(['success' => true]);
        $this->assertDatabaseHas('field_assessments', [
            'case_id' => $case->id,
            'volunteer_id' => $this->volunteer->id,
            'urgency_rating' => 'critical',
        ]);
    }

    /**
     * Stage 5: Physical NFC Card Tap -> Instant Delivery Verification & Double Dipping Prevention
     */
    public function test_stage_5_physical_nfc_card_tap_and_double_dipping_prevention(): void
    {
        // 1. Volunteer scans NFC card (UID: 04:DEF:01:23:45:67) via API lookup
        $lookupResponse = $this->postJson('/api/beneficiaries/lookup', [
            'token' => $this->beneficiary->nfc_card_uid,
        ], $this->authHeaders());

        $lookupResponse->assertStatus(200);
        $lookupResponse->assertJson([
            'success' => true,
            'data' => [
                'id' => $this->beneficiary->id,
                'national_id' => $this->beneficiary->national_id,
            ],
        ]);

        // 2. Perform aid distribution via NFC scan
        // Reset any existing distribution for this campaign/beneficiary
        AidDistribution::where('campaign_id', $this->campaign->id)
            ->where('beneficiary_id', $this->beneficiary->id)
            ->delete();

        $distributeResponse = $this->postJson('/api/distributions/verify-and-deliver', [
            'campaign_id' => $this->campaign->id,
            'token' => $this->beneficiary->nfc_card_uid,
            'verification_method' => 'nfc_tap',
            'notes' => 'تسليم معتمد بالبطاقة الذكية أمام لجنة التحكيم',
        ], $this->authHeaders());

        $distributeResponse->assertStatus(200);
        $distributeResponse->assertJson(['success' => true]);

        // Verify distribution recorded in DB
        $this->assertDatabaseHas('aid_distributions', [
            'campaign_id' => $this->campaign->id,
            'beneficiary_id' => $this->beneficiary->id,
            'verification_method' => 'nfc_tap',
        ]);

        // 3. Double Dipping Prevention: Immediate re-scan must be rejected!
        $duplicateResponse = $this->postJson('/api/distributions/verify-and-deliver', [
            'campaign_id' => $this->campaign->id,
            'token' => $this->beneficiary->nfc_card_uid,
            'verification_method' => 'nfc_tap',
        ], $this->authHeaders());

        $duplicateResponse->assertStatus(422);
        $duplicateResponse->assertJson(['success' => false]);
    }

    /**
     * Stage 6: Volunteer Digital Passport & Certified Resume Export with Verification QR
     */
    public function test_stage_6_volunteer_passport_and_verifiable_certificate_export(): void
    {
        // 1. Fetch volunteer passport
        $passportResponse = $this->getJson('/api/volunteer/passport/me', $this->authHeaders());
        $passportResponse->assertStatus(200);
        $passportResponse->assertJsonStructure([
            'success',
            'data' => [
                'name',
                'rank',
                'hours',
                'points',
                'badges',
                'certificate_verification_url',
            ],
        ]);

        // 2. Executive Annual Impact Report View
        $reportResponse = $this->get('/dashboard/reports/annual-impact');
        $reportResponse->assertStatus(200);
        $reportResponse->assertSee('تقرير الأثر الإنساني السنوي والشفافية الرقمية');
        $reportResponse->assertSee('المنع التام للازدواجية (NFC)');
    }

    /**
     * Full End-to-End Defense Walkthrough Chain
     */
    public function test_full_graduation_defense_lifecycle_e2e(): void
    {
        // GIS -> Case -> AI Triage -> Field Visit -> NFC Delivery -> Certificate
        $this->test_stage_1_web_dashboard_and_live_gis_operations_map();
        $this->test_stage_2_and_3_citizen_request_with_ai_audit_and_triage();
        $this->test_stage_4_volunteer_accepts_case_and_submits_field_assessment();
        $this->test_stage_5_physical_nfc_card_tap_and_double_dipping_prevention();
        $this->test_stage_6_volunteer_passport_and_verifiable_certificate_export();
    }
}
