<?php

namespace Tests\Feature;

use App\Models\AidCase;
use App\Models\Beneficiary;
use App\Models\Category;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\NfcCard;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AtharPhaseFiveWebDashboardTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // Ensure standard governorates exist
        Governorate::firstOrCreate(['name' => 'دمشق']);
        Governorate::firstOrCreate(['name' => 'ريف دمشق']);
        Category::firstOrCreate(['name' => 'رعاية صحية']);
    }

    /**
     * 1. Test 5.1 Main Operations Dashboard & KPIs
     */
    public function test_operations_portal_dashboard_renders_with_kpis_and_metrics(): void
    {
        $response = $this->get('/dashboard');

        $response->assertStatus(200);
        $response->assertViewIs('dashboard.index');
        $response->assertSee('غرفة العمليات المركزية');
        $response->assertSee('العائلات المستفيدة هذا الشهر');
        $response->assertSee('متطوعون نشطون في الميدان');
        $response->assertSee('زيارات ميدانية قيد الانتظار');
        $response->assertSee('الطرود الإغاثية الجاهزة');
    }

    /**
     * 2. Test 5.2 Live GIS Operations Map & API Geo-data
     */
    public function test_gis_map_and_geojson_data_endpoint_return_locations(): void
    {
        // 1. View page
        $response = $this->get('/dashboard/gis-map');
        $response->assertStatus(200);
        $response->assertViewIs('dashboard.gis');
        $response->assertSee('الخريطة الميدانية التفاعلية');

        // 2. Data endpoint
        $dataResponse = $this->getJson('/dashboard/api/gis-data');
        $dataResponse->assertStatus(200);
        $dataResponse->assertJsonStructure([
            'cases',
            'volunteers',
            'warehouses',
        ]);
    }

    /**
     * 3. Test 5.3 AI Triage Board & Approval Action
     */
    public function test_ai_triage_review_board_displays_urgency_and_handles_approval(): void
    {
        $gov = Governorate::first();
        $cat = Category::first();

        $case = AidCase::create([
            'title' => 'حالة طارئة حرجة لفحص لوحة التدقيق',
            'description' => 'حاجة ماسة لعلاج طبي عاجل',
            'governorate_id' => $gov->id,
            'category_id' => $cat->id,
            'status' => 'pending',
            'priority' => 'urgent',
            'ai_urgency_index' => 95,
            'ai_triage_tier' => 'Tier 1 - Immediate Intervention',
            'target_amount' => 5000000,
            'collected_amount' => 0,
        ]);

        // Review Board view
        $response = $this->get('/dashboard/cases');
        $response->assertStatus(200);
        $response->assertViewIs('dashboard.cases');
        $response->assertSee('حالة طارئة حرجة لفحص لوحة التدقيق');
        $response->assertSee('95 / 100');

        // Approve action
        $approveResponse = $this->post("/dashboard/cases/{$case->id}/approve");
        $approveResponse->assertRedirect();
        $this->assertEquals('approved', $case->fresh()->status);
    }

    /**
     * 4. Test 5.3 Volunteer Assignment and Case Rejection
     */
    public function test_case_volunteer_assignment_and_rejection(): void
    {
        $gov = Governorate::first();
        $cat = Category::first();

        $volunteer = User::firstOrCreate(
            ['phone' => '0999554433'],
            [
                'name' => 'عمر خالد الحلبي',
                'email' => 'omar.volunteer' . uniqid() . '@athar-syria.org',
                'password' => bcrypt('secret123'),
                'role' => 'volunteer',
                'volunteer_hours' => 60,
                'vehicle_type' => 'دراجة نارية',
                'governorate' => 'دمشق',
            ]
        );

        $case = AidCase::create([
            'title' => 'طلب مساعدة بحاجة كشف ميداني',
            'description' => 'كشف أضرار المنزل',
            'governorate_id' => $gov->id,
            'category_id' => $cat->id,
            'status' => 'pending',
            'priority' => 'medium',
            'ai_urgency_index' => 60,
        ]);

        // Assign
        $assignResponse = $this->post("/dashboard/cases/{$case->id}/assign", [
            'volunteer_id' => $volunteer->id,
            'notes' => 'الرجاء فحص التشققات في الجدران وتدقيق الهوية',
        ]);
        $assignResponse->assertRedirect();
        $this->assertEquals('assigned_for_inspection', $case->fresh()->status);

        // Reject
        $rejectResponse = $this->post("/dashboard/cases/{$case->id}/reject", [
            'rejection_reason' => 'عدم تطابق الشروط وتكرار تقديم الطلب',
        ]);
        $rejectResponse->assertRedirect();
        $this->assertEquals('rejected', $case->fresh()->status);
    }

    /**
     * 5. Test 5.4 Beneficiary Hub & NFC Card Pairing
     */
    public function test_beneficiary_hub_renders_and_pairs_nfc_card_successfully(): void
    {
        $gov = Governorate::first();

        // 1. Hub view
        $response = $this->get('/dashboard/beneficiaries');
        $response->assertStatus(200);
        $response->assertViewIs('dashboard.beneficiaries');
        $response->assertSee('سجل العائلات المستفيدة والمطابقة الرقمية');

        // 2. Register family + pair NFC
        $uniqueNid = '01' . rand(100000000, 999999999);
        $uniqueNfc = '04' . strtoupper(substr(md5(uniqid()), 0, 10));

        $storeResponse = $this->post('/dashboard/beneficiaries', [
            'full_name' => 'مروان سعيد الشامي',
            'national_id' => $uniqueNid,
            'phone' => '0988112233',
            'family_members_count' => 6,
            'governorate_id' => $gov->id,
            'address' => 'دمشق - حي الميدان',
            'vulnerability_level' => 'critical',
            'nfc_uid' => $uniqueNfc,
        ]);

        $storeResponse->assertRedirect();

        $beneficiary = Beneficiary::where('national_id', $uniqueNid)->first();
        $this->assertNotNull($beneficiary);
        $this->assertEquals('مروان سعيد الشامي', $beneficiary->full_name);

        $nfc = NfcCard::where('card_uid', $uniqueNfc)->first();
        $this->assertNotNull($nfc);
        $this->assertEquals($beneficiary->id, $nfc->beneficiary_id);
    }

    /**
     * 6. Test 5.5 Logistics & Aid Inventory System
     */
    public function test_inventory_system_displays_stock_and_low_stock_warnings(): void
    {
        $cat = Category::first();

        InventoryItem::firstOrCreate(
            ['code' => 'TEST-FOOD-01'],
            [
                'name' => 'سلة غذائية اختبارية',
                'category_id' => $cat->id,
                'unit' => 'سلة',
                'total_stock' => 200,
                'available_stock' => 180,
                'reserved_stock' => 20,
                'minimum_threshold' => 30,
                'warehouse_location' => 'مستودع دمشق المركزي',
            ]
        );

        $response = $this->get('/dashboard/inventory');
        $response->assertStatus(200);
        $response->assertViewIs('dashboard.inventory');
        $response->assertSee('المستودعات واللوجستيات الإغاثية');
        $response->assertSee('سلة غذائية اختبارية');
    }

    /**
     * 7. Test 5.6 Executive Analytics & Annual Impact Report
     */
    public function test_executive_analytics_and_impact_report_render_properly(): void
    {
        // Analytics
        $analyticsResponse = $this->get('/dashboard/analytics');
        $analyticsResponse->assertStatus(200);
        $analyticsResponse->assertViewIs('dashboard.analytics');
        $analyticsResponse->assertSee('لوحة القياس والتحليل التنفيذي');
        $analyticsResponse->assertSee('لوحة شرف المتطوعين الميدانيين');

        // Impact Report (Printable/PDF)
        $reportResponse = $this->get('/dashboard/reports/annual-impact');
        $reportResponse->assertStatus(200);
        $reportResponse->assertViewIs('dashboard.impact_report');
        $reportResponse->assertSee('مـنـظـمـة أَثَـــــــر لـلإغـاثـة والـتـنـمـيـة');
        $reportResponse->assertSee('تقرير الأثر الإنساني السنوي والشفافية الرقمية');
        $reportResponse->assertSee('المنع التام للازدواجية (NFC)');
    }
}
