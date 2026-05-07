<?php

namespace Database\Seeders;

use App\Models\AidCase;
use App\Models\User;
use App\Models\VolunteerOpportunity;
use App\Models\Governorate;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $organizations = collect([
            ['name' => 'Alkhair', 'email' => 'org1@example.com', 'phone' => '0910000001'],
            ['name' => 'Alamal', 'email' => 'org2@example.com', 'phone' => '0910000002'],
            ['name' => 'Alnour', 'email' => 'org3@example.com', 'phone' => '0910000003'],
            ['name' => 'Alaun', 'email' => 'org4@example.com', 'phone' => '0910000004'],
            ['name' => 'Basmah', 'email' => 'org5@example.com', 'phone' => '0910000005'],
        ])->map(function ($org) {
            return User::updateOrCreate(
                ['email' => $org['email']],
                [
                    'name' => $org['name'],
                    'phone' => $org['phone'],
                    'password' => Hash::make('password'),
                    'role' => 'organization',
                    'is_active' => true,
                ]
            );
        });

        collect([
            ['name' => 'Ibrahim', 'email' => 'ibrahim@example.com', 'phone' => '0920000001'],
            ['name' => 'Khalil', 'email' => 'khalil@example.com', 'phone' => '0920000002'],
            ['name' => 'Sara', 'email' => 'sara@example.com', 'phone' => '0920000003'],
            ['name' => 'Maya', 'email' => 'maya@example.com', 'phone' => '0920000004'],
            ['name' => 'Nad', 'email' => 'nad@example.com', 'phone' => '0920000005'],
        ])->each(function ($vol) {
            User::updateOrCreate(
                ['email' => $vol['email']],
                [
                    'name' => $vol['name'],
                    'phone' => $vol['phone'],
                    'password' => Hash::make('pppppppp'),
                    'role' => 'volunteer',
                    'is_active' => true,
                ]
            );
        });

        $primaryOrganization = $organizations->first();
        
        // Get governorates dynamically
        $governorates = Governorate::all();
        $damascus = $governorates->where('name', 'دمشق')->first();
        $aleppo = $governorates->where('name', 'حلب')->first();
        $homs = $governorates->where('name', 'حمص')->first();
        $hama = $governorates->where('name', 'حماة')->first();

        $cases = [
            [
                'title' => 'مساعدة عاجلة لعائلة متضررة',
                'description' => 'عائلة مكونة من 5 أفراد بحاجة لمساعدة عاجلة للإيجار والطعام بعد فقدان مصدر الدخل.',
                'status' => 'approved',
                'priority' => 'high',
                'category_id' => 1,
                'governorate_id' => $damascus->id,
                'organization_id' => $primaryOrganization->id,
                'views' => 120,
            ],
            [
                'title' => 'علاج طبي لطفل مصاب',
                'description' => 'طفل يعاني من مرض نادر ويحتاج لعملية جراحية عاجلة.',
                'status' => 'approved',
                'priority' => 'urgent',
                'category_id' => 3,
                'governorate_id' => $aleppo->id,
                'organization_id' => $primaryOrganization->id,
                'views' => 230,
            ],
            [
                'title' => 'مساعدات غذائية لأسرة فقيرة',
                'description' => 'أسرة مكونة من 7 أفراد بحاجة لسلة غذائية شهرية.',
                'status' => 'approved',
                'priority' => 'medium',
                'category_id' => 2,
                'governorate_id' => $homs->id,
                'organization_id' => $primaryOrganization->id,
                'views' => 89,
            ],
            [
                'title' => 'دعم تعليمي لطالب مجتهد',
                'description' => 'طالب متفوق يحتاج لدعم مالي لاستكمال دراسته الجامعية.',
                'status' => 'approved',
                'priority' => 'medium',
                'category_id' => 4,
                'governorate_id' => $damascus->id,
                'organization_id' => $primaryOrganization->id,
                'views' => 156,
            ],
            [
                'title' => 'إعادة تأهيل منزل متضرر',
                'description' => 'منزل تضرر بسبب الأمطار ويحتاج لإصلاحات عاجلة.',
                'status' => 'approved',
                'priority' => 'high',
                'category_id' => 5,
                'governorate_id' => $hama->id,
                'organization_id' => $primaryOrganization->id,
                'views' => 67,
            ],
        ];

        foreach ($cases as $caseData) {
            AidCase::create($caseData);
        }

        $opportunities = [
            [
                'title' => 'توزيع سلال غذائية على الأسر المحتاجة',
                'description' => 'نحتاج متطوعين لتوزيع 50 سلة غذائية على الأسر المحتاجة.',
                'category' => 'مساعدات غذائية',
                'governorate' => 'دمشق',
                'priority' => 'high',
                'organization_id' => $primaryOrganization->id,
                'volunteers_needed' => 10,
                'volunteers_applied' => 4,
                'is_urgent' => true,
            ],
            [
                'title' => 'مساعدة في حملة تبرع بالدم',
                'description' => 'نحتاج متطوعين للتسجيل والتنظيم في حملة التبرع بالدم.',
                'category' => 'علاج طبي',
                'governorate' => 'حلب',
                'priority' => 'urgent',
                'organization_id' => $primaryOrganization->id,
                'volunteers_needed' => 6,
                'volunteers_applied' => 2,
                'is_urgent' => true,
            ],
            [
                'title' => 'تدريس الأطفال المحرومين',
                'description' => 'برنامج تعليمي للأطفال في المناطق النائية.',
                'category' => 'تعليم',
                'governorate' => 'حمص',
                'priority' => 'medium',
                'organization_id' => $primaryOrganization->id,
                'volunteers_needed' => 4,
                'volunteers_applied' => 1,
            ],
        ];

        foreach ($opportunities as $opportunity) {
            VolunteerOpportunity::create($opportunity);
        }
    }
}
