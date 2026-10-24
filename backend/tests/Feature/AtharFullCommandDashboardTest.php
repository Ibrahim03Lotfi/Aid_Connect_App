<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Governorate;
use Tests\TestCase;

class AtharFullCommandDashboardTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Governorate::firstOrCreate(['name' => 'دمشق']);
        Category::firstOrCreate(['name' => 'رعاية صحية']);
    }

    public function test_all_enterprise_dashboard_routes_render_successfully(): void
    {
        $routes = [
            '/dashboard',
            '/dashboard/gis-map',
            '/dashboard/campaigns',
            '/dashboard/cases',
            '/dashboard/ai-intelligence',
            '/dashboard/assessments',
            '/dashboard/missions',
            '/dashboard/beneficiaries',
            '/dashboard/distributions',
            '/dashboard/inventory',
            '/dashboard/volunteers',
            '/dashboard/organizations',
            '/dashboard/users',
            '/dashboard/donations',
            '/dashboard/analytics',
            '/dashboard/notifications',
            '/dashboard/settings',
            '/dashboard/reports/annual-impact',
        ];

        foreach ($routes as $route) {
            $response = $this->get($route);
            $response->assertStatus(200, "Route {$route} failed to return HTTP 200");
        }
    }

    public function test_enterprise_operations_post_actions(): void
    {
        $gov = Governorate::first();
        $cat = Category::first();

        // 1. Campaign store & toggle
        $campResponse = $this->post('/dashboard/campaigns', [
            'title' => 'حملة إغاثة مؤتمتة للمحافظات المنكوبة',
            'category_id' => $cat->id,
            'start_date' => now()->toDateString(),
            'end_date' => now()->addMonth()->toDateString(),
            'item_type' => 'سلة غذائية',
            'target_families_count' => 500,
            'items_allocated_per_family' => 1,
        ]);
        $campResponse->assertRedirect();
        $campaign = \App\Models\AidCampaign::where('title', 'حملة إغاثة مؤتمتة للمحافظات المنكوبة')->first();
        $this->assertNotNull($campaign);

        $toggleResponse = $this->post("/dashboard/campaigns/{$campaign->id}/toggle-status");
        $toggleResponse->assertRedirect();

        // 2. Emergency Mission store & close
        $missionResponse = $this->post('/dashboard/missions', [
            'title' => 'مهمة إسعاف وتدخل طارئ',
            'description' => 'انهيار مبنى سكني بحاجة لكادر فوري',
            'urgency' => 'critical',
            'governorate_id' => $gov->id,
            'district' => 'الميدان',
            'volunteers_needed' => 8,
            'required_skills' => 'إسعاف أولي, إخلاء',
        ]);
        $missionResponse->assertRedirect();
        $mission = \App\Models\EmergencyMission::where('title', 'مهمة إسعاف وتدخل طارئ')->first();
        $this->assertNotNull($mission);

        $closeResponse = $this->post("/dashboard/missions/{$mission->id}/close");
        $closeResponse->assertRedirect();
        $this->assertEquals('completed', $mission->fresh()->status);

        // 3. Stock Intake (+IN)
        $item = \App\Models\InventoryItem::firstOrCreate(
            ['code' => 'TEST-STOCK-01'],
            ['name' => 'طرد اختبار', 'category_id' => $cat->id, 'unit' => 'طرد', 'total_stock' => 50, 'available_stock' => 50, 'reserved_stock' => 0, 'minimum_threshold' => 10]
        );
        $initialStock = $item->available_stock;
        $stockResponse = $this->post('/dashboard/inventory/add-stock', [
            'item_id' => $item->id,
            'quantity' => 25,
            'notes' => 'شحنة اختبار مركزية',
        ]);
        $stockResponse->assertRedirect();
        $this->assertEquals($initialStock + 25, $item->fresh()->available_stock);

        // 4. Volunteer Opportunities Store
        $opResponse = $this->post('/dashboard/volunteers/opportunities', [
            'title' => 'فريق الدعم اللوجستي المركزي',
            'description' => 'المساعدة في تنظيم المستودعات ونقل المواد',
            'category' => 'سلة غذائية',
            'governorate' => 'دمشق',
            'priority' => 'high',
            'volunteers_needed' => 15,
            'is_urgent' => 1,
        ]);
        $opResponse->assertRedirect();
        $this->assertDatabaseHas('volunteer_opportunities', ['title' => 'فريق الدعم اللوجستي المركزي']);

        // 5. Emergency Notification Broadcast
        $broadcastResponse = $this->post('/dashboard/notifications/broadcast', [
            'title' => 'تنبيه عملياتي هام',
            'body' => 'يرجى مراجعة نقاط التوزيع المحددة فوراً',
            'target' => 'all',
        ]);
        $broadcastResponse->assertRedirect();
        $this->assertDatabaseHas('notifications', ['title' => 'تنبيه عملياتي هام']);

        // 6. AI Triage Simulation
        $aiResponse = $this->post('/dashboard/ai-intelligence/simulate', [
            'title' => 'عملية قلب مفتوح لطفل رضيع',
            'description' => 'حالة حرجة جدا في العناية المشددة بحاجة تدخل جراحي عاجل',
        ]);
        $aiResponse->assertRedirect();
        $aiResponse->assertSessionHas('simulation_result');

        // 7. User Status Toggle & Role Update
        $testUser = \App\Models\User::create([
            'name' => 'مستخدم اختبار الحوكمة',
            'email' => 'governance.test.' . uniqid() . '@athar.sy',
            'phone' => '09' . rand(10000000, 99999999),
            'password' => bcrypt('password'),
            'role' => 'user',
            'is_active' => true,
        ]);
        $toggleUserResponse = $this->post("/dashboard/users/{$testUser->id}/toggle-status");
        $toggleUserResponse->assertRedirect();
        $this->assertEquals(false, $testUser->fresh()->is_active);

        $roleResponse = $this->post("/dashboard/users/{$testUser->id}/update-role", ['role' => 'volunteer']);
        $roleResponse->assertRedirect();
        $this->assertEquals('volunteer', $testUser->fresh()->role);
        $testUser->delete();

        // 8. Settings Category & Governorate Store
        $catStoreResponse = $this->post('/dashboard/settings/categories', ['name' => 'كسوة الشتاء الشاملة ' . uniqid()]);
        $catStoreResponse->assertRedirect();

        $govStoreResponse = $this->post('/dashboard/settings/governorates', ['name' => 'طرطوس ' . uniqid()]);
        $govStoreResponse->assertRedirect();

        // 9. Reopen Mission
        $reopenResponse = $this->post("/dashboard/missions/{$mission->id}/reopen");
        $reopenResponse->assertRedirect();
        $this->assertEquals('open', $mission->fresh()->status);

        // 10. Field Assessment Status Updates (submitted -> approved -> rejected)
        $assessment = \App\Models\FieldAssessment::first();
        if ($assessment) {
            $assessResponse = $this->post("/dashboard/assessments/{$assessment->id}/status", ['status' => 'submitted']);
            $assessResponse->assertRedirect();
            $this->assertEquals('submitted', $assessment->fresh()->status);

            $this->post("/dashboard/assessments/{$assessment->id}/status", ['status' => 'approved'])->assertRedirect();
            $this->assertEquals('approved', $assessment->fresh()->status);
        }

        // 11. Donation Approval and Rejection
        $case = \App\Models\AidCase::first();
        $donation = \App\Models\CaseDonation::firstOrCreate(
            ['transaction_ref' => 'REF-TEST-PENDING'],
            [
                'case_id' => $case->id,
                'amount' => 50000,
                'currency' => 'ل.س',
                'payment_method' => 'sham_cash',
                'donor_name' => 'متبرع تجريبي',
                'status' => 'pending',
            ]
        );
        $this->post("/dashboard/donations/{$donation->id}/approve")->assertRedirect();
        $this->assertEquals('completed', $donation->fresh()->status);

        $this->post("/dashboard/donations/{$donation->id}/reject")->assertRedirect();
        $this->assertEquals('failed', $donation->fresh()->status);

        // 12. Volunteer Opportunity Toggle Status
        $opportunity = \App\Models\VolunteerOpportunity::first();
        if ($opportunity) {
            $prevOpStatus = $opportunity->status;
            $this->post("/dashboard/volunteers/opportunities/{$opportunity->id}/toggle-status")->assertRedirect();
            $this->assertNotEquals($prevOpStatus, $opportunity->fresh()->status);
        }
    }
}
