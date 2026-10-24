<?php

namespace Database\Seeders;

use App\Models\AidCampaign;
use App\Models\Beneficiary;
use App\Models\Category;
use App\Models\EmergencyMission;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\NfcCard;
use App\Models\User;
use App\Models\VolunteerOpportunity;
use Illuminate\Database\Seeder;

class AtharOperationsSeeder extends Seeder
{
    public function run(): void
    {
        $damascus = Governorate::where('name', 'دمشق')->first();
        $ruralDamascus = Governorate::where('name', 'ريف دمشق')->first() ?? $damascus;
        $aleppo = Governorate::where('name', 'حلب')->first() ?? $damascus;

        $foodCategory = Category::where('name', 'like', '%غذاء%')->orWhere('name', 'like', '%طعام%')->first() ?? Category::first();
        $healthCategory = Category::where('name', 'like', '%صح%')->orWhere('name', 'like', '%طب%')->first() ?? Category::first();
        $shelterCategory = Category::where('name', 'like', '%سكن%')->orWhere('name', 'like', '%مأوى%')->first() ?? Category::first();

        // 1. Seed Active Campaigns
        $winterCampaign = AidCampaign::updateOrCreate(
            ['title' => 'حملة دفء الشتاء للإغاثة العاجلة 2026'],
            [
                'description' => 'توزيع بطانيات حرارية وسلات غذائية للمتضررين من موجة البرد القارس في ريف دمشق.',
                'category_id' => $shelterCategory->id,
                'start_date' => now()->subDays(5),
                'end_date' => now()->addDays(25),
                'status' => 'active',
                'item_type' => 'سلة شتوية (بطانيتان + معونة غذائية)',
                'items_allocated_per_family' => 1,
                'target_families_count' => 350,
                'distributed_families_count' => 48,
            ]
        );

        $foodCampaign = AidCampaign::updateOrCreate(
            ['title' => 'حملة السلة الغذائية الكبرى - قطاع دمشق'],
            [
                'description' => 'توزيع السلات الغذائية الشهرية للعائلات المسجلة والأشد فقراً.',
                'category_id' => $foodCategory->id,
                'start_date' => now()->subDays(12),
                'end_date' => now()->addDays(18),
                'status' => 'active',
                'item_type' => 'سلة غذائية متكاملة (15 كغ)',
                'items_allocated_per_family' => 1,
                'target_families_count' => 500,
                'distributed_families_count' => 112,
            ]
        );

        // 2. Seed Warehouse Inventory
        $inventory = [
            [
                'name' => 'سلة غذائية متكاملة (زيت، سكر، رز، برغل، معلبات)',
                'code' => 'FOOD-BOX-15KG',
                'category_id' => $foodCategory->id,
                'unit' => 'سلة',
                'total_stock' => 450,
                'available_stock' => 380,
                'reserved_stock' => 70,
                'minimum_threshold' => 50,
                'warehouse_location' => 'مستودع الميدان المركزي',
            ],
            [
                'name' => 'بطانية صوفية حرارية شتوية مزدوجة',
                'code' => 'SHELTER-BLKT-01',
                'category_id' => $shelterCategory->id,
                'unit' => 'بطانية',
                'total_stock' => 600,
                'available_stock' => 550,
                'reserved_stock' => 50,
                'minimum_threshold' => 100,
                'warehouse_location' => 'مستودع صحنايا الإقليمي',
            ],
            [
                'name' => 'حقيبة إسعاف أولي وأدوية ضغط وسكر',
                'code' => 'MED-KIT-CHRONIC',
                'category_id' => $healthCategory->id,
                'unit' => 'حقيبة',
                'total_stock' => 120,
                'available_stock' => 110,
                'reserved_stock' => 10,
                'minimum_threshold' => 20,
                'warehouse_location' => 'صيدلية أثر الميدانية',
            ],
        ];

        foreach ($inventory as $itemData) {
            InventoryItem::updateOrCreate(['code' => $itemData['code']], $itemData);
        }

        // 3. Seed Beneficiary Families with NFC cards and QR codes
        $beneficiaries = [
            [
                'full_name' => 'محمد أحمد الصالح (أبو أحمد)',
                'national_id' => '01010045891',
                'phone' => '0933112233',
                'family_members_count' => 6,
                'governorate_id' => $ruralDamascus->id,
                'district' => 'جرمانا - حي الروضة',
                'address_details' => 'نزلة جامع النور، بناء السلام، الطابق الأرضي',
                'latitude' => 33.4833,
                'longitude' => 36.3500,
                'vulnerability_score' => 88,
                'nfc_card_uid' => '04:A2:3B:5C:8D:1E:80',
                'qr_token' => 'ATHAR-FAM-DAM01',
                'status' => 'active',
                'notes' => 'رب الأسرة مصاب ويعيل أطفالاً قاصرين.',
            ],
            [
                'full_name' => 'فاطمة محمود الكردي (أم يوسف)',
                'national_id' => '02040089123',
                'phone' => '0944556677',
                'family_members_count' => 4,
                'governorate_id' => $aleppo->id,
                'district' => 'حلب - حي السليمانية',
                'address_details' => 'قرب مشفى حلب الجامعي، حارة الياسمين',
                'latitude' => 36.2167,
                'longitude' => 37.1500,
                'vulnerability_score' => 92,
                'nfc_card_uid' => '04:B4:7C:1D:9F:2A:80',
                'qr_token' => 'ATHAR-FAM-ALP02',
                'status' => 'active',
                'notes' => 'أرملة تعيل 3 أيتام، تحتاج دعماً شهرياً ومتابعة طبية.',
            ],
            [
                'full_name' => 'سامر عدنان النجار',
                'national_id' => '01080034567',
                'phone' => '0955889900',
                'family_members_count' => 5,
                'governorate_id' => $damascus->id,
                'district' => 'دمشق - باب سريجة',
                'address_details' => 'زقاق العطارين، دخلة البيت القديم',
                'latitude' => 33.5080,
                'longitude' => 36.2950,
                'vulnerability_score' => 74,
                'nfc_card_uid' => '04:C5:8E:2F:0A:3B:80',
                'qr_token' => 'ATHAR-FAM-DAM03',
                'status' => 'active',
                'notes' => 'عائلة مهجرة تسكن في غرفة إيجار.',
            ],
        ];

        foreach ($beneficiaries as $benData) {
            $b = Beneficiary::updateOrCreate(['national_id' => $benData['national_id']], $benData);
            if (!empty($benData['nfc_card_uid'])) {
                NfcCard::updateOrCreate(
                    ['card_uid' => $benData['nfc_card_uid']],
                    [
                        'beneficiary_id' => $b->id,
                        'is_active' => true,
                        'issued_at' => now()->subMonths(1),
                    ]
                );
            }
        }

        // 4. Seed Emergency Missions
        $admin = User::where('role', 'organization')->first() ?? User::first();
        if ($admin) {
            EmergencyMission::updateOrCreate(
                ['title' => 'استجابة عاجلة لموجة الصقيع في مخيمات ريف دمشق'],
                [
                    'description' => 'مهمة إسعافية عاجلة لتوزيع أغطية حرارية ووقود تدفئة لعشرات العائلات المحاصرة بالثلوج.',
                    'urgency' => 'critical',
                    'required_skills' => ['مسعف', 'سائق سيارة دفع رباعي', 'لوجستي'],
                    'governorate_id' => $ruralDamascus->id,
                    'district' => 'منطقة القلمون / يبرود',
                    'latitude' => 33.9667,
                    'longitude' => 36.6500,
                    'volunteers_needed' => 6,
                    'volunteers_joined' => 2,
                    'status' => 'open',
                    'created_by' => $admin->id,
                ]
            );

            EmergencyMission::updateOrCreate(
                ['title' => 'حملة تبرع بالدم طارئة لمشفى المواساة'],
                [
                    'description' => 'نداء عاجل لتنظيم متبرعين بالدم من زمرة O- و AB- لمرضى الحوادث والعمليات الجراحية.',
                    'urgency' => 'high',
                    'required_skills' => ['مسعف', 'تنظيم ميداني'],
                    'governorate_id' => $damascus->id,
                    'district' => 'المزة - مشفى المواساة',
                    'latitude' => 33.5130,
                    'longitude' => 36.2670,
                    'volunteers_needed' => 4,
                    'volunteers_joined' => 3,
                    'status' => 'open',
                    'created_by' => $admin->id,
                ]
            );
        }

        // 5. Enrich Demo Volunteers with Points & Badges
        $volunteer = User::where('role', 'volunteer')->first();
        if ($volunteer) {
            $volunteer->volunteer_rank = 'مسعف إغاثي أول';
            $volunteer->volunteer_points = 320;
            $volunteer->volunteer_hours = 42.5;
            $volunteer->badges = [
                'المستجيب السريع',
                'موثق البطاقات الذكية',
                'نجم العطاء الميداني',
            ];
            $volunteer->has_vehicle = true;
            $volunteer->availability_time = 'متفرغ لنهاية الأسبوع';
            $volunteer->save();
        }

        // 6. Seed Realistic Comments and Sham Cash Donations
        $sampleCases = \App\Models\AidCase::take(5)->get();
        $sampleUser = User::first();
        if ($sampleUser && $sampleCases->isNotEmpty()) {
            foreach ($sampleCases as $c) {
                $c->update([
                    'target_amount' => 2500000,
                    'collected_amount' => 1850000,
                    'likes_count' => rand(45, 180),
                ]);

                \App\Models\CaseComment::firstOrCreate([
                    'case_id' => $c->id,
                    'user_id' => $sampleUser->id,
                    'comment' => 'تم الكشف الميداني وتوثيق الوضع، الحالة تستحق الدعم العاجل جزاكم الله خيراً.',
                ]);
                \App\Models\CaseComment::firstOrCreate([
                    'case_id' => $c->id,
                    'user_id' => $volunteer ? $volunteer->id : $sampleUser->id,
                    'comment' => 'تم التبرع بمبلغ 50,000 ل.س عبر شام كاش، أسأل الله الفرج للعائلة.',
                ]);
            }
        }

        // 7. Seed Inventory Transactions
        $items = InventoryItem::take(3)->get();
        if ($items->isNotEmpty() && $admin) {
            foreach ($items as $item) {
                \App\Models\InventoryTransaction::updateOrCreate(
                    [
                        'item_id' => $item->id,
                        'type' => 'inbound',
                        'quantity' => 100,
                    ],
                    [
                        'performed_by' => $admin->id,
                        'notes' => 'توريد دفعة إغاثية جديدة من المستودع المركزي بدمشق.',
                    ]
                );
            }
        }

        // 8. Seed Field Assessments
        $beneficiariesList = Beneficiary::take(3)->get();
        if ($sampleCases->isNotEmpty() && $volunteer) {
            $assessmentStatuses = ['submitted', 'approved', 'rejected'];
            $inspectorNotes = [
                'تمت معاينة الأسرة ميدانياً، الوضع المعيشي قاسٍ للغاية وبحاجة إلى دعم فوري وتوفير مستلزمات التدفئة.',
                'المنزل متصدع بفعل الرطوبة ونقص الترميم، العائلة تتألف من 6 أفراد دون معيل ثابت، يوصى بالاعتماد الفوري.',
                'الأسرة تمتلك دخلاً إضافياً ولا تنطبق عليها معايير الهشاشة الحرجة للمنحة الحالية.',
            ];
            foreach ($beneficiariesList as $idx => $b) {
                $case = $sampleCases->get($idx) ?? $sampleCases->first();
                \App\Models\FieldAssessment::updateOrCreate(
                    ['case_id' => $case->id, 'beneficiary_id' => $b->id],
                    [
                        'volunteer_id' => $volunteer->id,
                        'living_condition_score' => 9 - ($idx * 3),
                        'housing_type' => $idx === 0 ? 'مأوى مؤقت غير مؤهل' : ($idx === 1 ? 'منزل مستأجر متضرر جزئياً' : 'شقة سكنية عادية'),
                        'heating_available' => $idx === 2,
                        'monthly_income_estimate' => 350000 - ($idx * 100000),
                        'income_source' => $idx === 2 ? 'موظف قطاع خاص' : 'مياومة متقطعة لا تكفي الغذاء والدواء',
                        'urgency_rating' => $idx === 0 ? 'critical' : ($idx === 1 ? 'high' : 'normal'),
                        'inspector_notes' => $inspectorNotes[$idx] ?? 'تمت المعاينة والتوثيق.',
                        'ai_damage_assessment' => $idx === 0 ? 'رصد تصدعات جدارية خطيرة في الأسقف وهشاشة إنشائية تتطلب تدخلاً سريعاً.' : 'أضرار سطحية مع رطوبة متوسطة.',
                        'status' => $assessmentStatuses[$idx] ?? 'submitted',
                        'visited_at' => now()->subDays(3 + $idx),
                    ]
                );
            }
        }

        // 9. Seed Aid Distributions
        if ($winterCampaign && $beneficiariesList->isNotEmpty() && $volunteer) {
            foreach ($beneficiariesList as $idx => $b) {
                \App\Models\AidDistribution::updateOrCreate(
                    ['campaign_id' => $winterCampaign->id, 'beneficiary_id' => $b->id],
                    [
                        'volunteer_id' => $volunteer->id,
                        'verification_method' => $idx === 0 ? 'nfc_tap' : ($idx === 1 ? 'qr_scan' : 'nfc_tap'),
                        'latitude' => $b->latitude ?? 33.4833,
                        'longitude' => $b->longitude ?? 36.3500,
                        'distributed_at' => now()->subDays($idx + 1),
                        'is_offline_synced' => $idx === 1,
                        'notes' => 'تم تسليم السلة والبطانيات بنجاح والتحقق عبر البطاقة الذكية دون أية معوقات.',
                    ]
                );
            }
        }

        // 10. Seed Volunteer Applications and Logs
        $opps = VolunteerOpportunity::take(2)->get();
        $applicantUser = User::where('role', 'donor')->first() ?: ($volunteer ?: User::first());
        if ($volunteer && $opps->isNotEmpty()) {
            foreach ($opps as $idx => $opp) {
                $status = ($idx === 0) ? 'pending' : 'accepted';
                $userForApp = ($idx === 0 && $applicantUser) ? $applicantUser : $volunteer;
                \App\Models\VolunteerApplication::updateOrCreate(
                    ['user_id' => $userForApp->id, 'opportunity_id' => $opp->id],
                    [
                        'status' => $status,
                        'case_title' => $opp->title,
                        'organization_name' => 'منظمة أثر للإغاثة والتنمية',
                        'category' => $opp->category,
                    ]
                );

                \App\Models\VolunteerLog::updateOrCreate(
                    ['volunteer_id' => $volunteer->id, 'reference_id' => $opp->id],
                    [
                        'mission_type' => 'field_assessment',
                        'hours_logged' => 4.5,
                        'points_earned' => 45,
                        'badge_awarded' => 'المستجيب السريع',
                        'verified_by_admin' => true,
                    ]
                );
            }
        }

        // 11. Seed Realistic Organization Partnership Requests
        \App\Models\OrganizationRequest::updateOrCreate(
            ['email' => 'ihsan.aleppo@ngo.sy'],
            [
                'name' => 'جمعية الإحسان الخيرية والإغاثية - قطاع حلب',
                'phone' => '021-2244660',
                'address' => 'حلب - السليمانية - شارع المدارس',
                'description' => 'جمعية أهلية تعنى برعاية الأيتام وتوزيع السلات الغذائية في أحياء حلب القديمة والمحررة.',
                'registration_number' => 'SY-NGO-ALP-2024-88',
                'status' => 'pending',
            ]
        );

        \App\Models\OrganizationRequest::updateOrCreate(
            ['email' => 'orphans.damascus@ngo.sy'],
            [
                'name' => 'جمعية رعاية الأيتام والمحتاجين بدمشق',
                'phone' => '011-3322110',
                'address' => 'دمشق - الميدان - قرب جامع منجك',
                'description' => 'منظمة إنسانية مشهرة تعنى بكفالة الأيتام وتوزيع المساعدات التعليمية والغذائية.',
                'registration_number' => 'SY-NGO-DAM-2023-14',
                'status' => 'approved',
            ]
        );

        \App\Models\OrganizationRequest::updateOrCreate(
            ['email' => 'hope.youth@mail.sy'],
            [
                'name' => 'مبادرة شباب الأمل التطوعية غير المشهرة',
                'phone' => '0991234567',
                'address' => 'ريف دمشق - جرمانا',
                'description' => 'مبادرة شبابية تطلب رخصة إطلاق حملات تبرع مالية.',
                'registration_number' => 'SY-TEMP-992',
                'status' => 'rejected',
                'rejection_reason' => 'عدم وجود ترخيص إشهار رسمي صادر عن وزارة الشؤون الاجتماعية والعمل.',
            ]
        );

        // 12. Seed Case Donations (Completed and Pending for Testing Actions)
        if ($sampleCases->isNotEmpty()) {
            $donorUser = User::where('role', 'donor')->first();
            $targetCase = $sampleCases->first();

            \App\Models\CaseDonation::updateOrCreate(
                ['transaction_ref' => 'REF-SHAM-9081A'],
                [
                    'case_id' => $targetCase->id,
                    'user_id' => $donorUser?->id,
                    'amount' => 750000,
                    'currency' => 'ل.س',
                    'payment_method' => 'sham_cash',
                    'donor_name' => 'المهندس وسيم الأحمد',
                    'donor_phone' => '0933112233',
                    'status' => 'completed',
                ]
            );

            \App\Models\CaseDonation::updateOrCreate(
                ['transaction_ref' => 'REF-SYRI-5542B'],
                [
                    'case_id' => $targetCase->id,
                    'user_id' => null,
                    'amount' => 300000,
                    'currency' => 'ل.س',
                    'payment_method' => 'syriatel_cash',
                    'donor_name' => 'فاعل خير من دمشق',
                    'donor_phone' => '0988776655',
                    'status' => 'pending',
                ]
            );

            $secondCase = $sampleCases->skip(1)->first() ?? $targetCase;

            \App\Models\CaseDonation::updateOrCreate(
                ['transaction_ref' => 'REF-CASH-1123C'],
                [
                    'case_id' => $secondCase->id,
                    'user_id' => null,
                    'amount' => 1200000,
                    'currency' => 'ل.س',
                    'payment_method' => 'manual',
                    'donor_name' => 'الحاج مأمون العطار',
                    'donor_phone' => '0944556677',
                    'status' => 'completed',
                ]
            );
        }
    }
}
