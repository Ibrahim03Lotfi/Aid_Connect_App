<?php

namespace Database\Seeders;

use App\Models\AidCase;
use App\Models\User;
use App\Models\VolunteerOpportunity;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $organization = User::create([
            'name' => 'منظمة الخير للإغاثة',
            'email' => 'org@example.com',
            'phone' => '0123456789',
            'password' => Hash::make('password'),
            'role' => 'organization',
            'is_active' => true,
        ]);

        $volunteer = User::create([
            'name' => 'أحمد محمد',
            'email' => 'volunteer@example.com',
            'phone' => '01012345678',
            'password' => Hash::make('password'),
            'role' => 'volunteer',
            'is_active' => true,
        ]);

        $user = User::create([
            'name' => 'مستخدم تجريبي',
            'email' => 'user@example.com',
            'phone' => '01111111111',
            'password' => Hash::make('password'),
            'role' => 'user',
            'is_active' => true,
        ]);

        $cases = [
            [
                'title' => 'مساعدة عاجلة لعائلة متضررة',
                'description' => 'عائلة مكونة من 5 أفراد بحاجة لمساعدة عاجلة للإيجار والطعام بعد فقدان مصدر الدخل.',
                'status' => 'approved',
                'priority' => 'high',
                'category_id' => 1,
                'governorate_id' => 1,
                'organization_id' => $organization->id,
                'views' => 120,
            ],
            [
                'title' => 'علاج طبي لطفل مصاب',
                'description' => 'طفل يعاني من مرض نادر ويحتاج لعملية جراحية عاجلة.',
                'status' => 'approved',
                'priority' => 'urgent',
                'category_id' => 3,
                'governorate_id' => 2,
                'organization_id' => $organization->id,
                'views' => 230,
            ],
            [
                'title' => 'مساعدات غذائية لأسرة فقيرة',
                'description' => 'أسرة مكونة من 7 أفراد بحاجة لسلة غذائية شهرية.',
                'status' => 'approved',
                'priority' => 'medium',
                'category_id' => 2,
                'governorate_id' => 3,
                'organization_id' => $organization->id,
                'views' => 89,
            ],
            [
                'title' => 'دعم تعليمي لطالب مجتهد',
                'description' => 'طالب متفوق يحتاج لدعم مالي لاستكمال دراسته الجامعية.',
                'status' => 'approved',
                'priority' => 'medium',
                'category_id' => 4,
                'governorate_id' => 1,
                'organization_id' => $organization->id,
                'views' => 156,
            ],
            [
                'title' => 'إعادة تأهيل منزل متضرر',
                'description' => 'منزل تضرر بسبب الأمطار ويحتاج لإصلاحات عاجلة.',
                'status' => 'approved',
                'priority' => 'high',
                'category_id' => 5,
                'governorate_id' => 4,
                'organization_id' => $organization->id,
                'views' => 67,
            ],
        ];

        foreach ($cases as $caseData) {
            AidCase::create($caseData);
        }

        $opportunities = [
            [
                'title' => 'توزيع سلال غذائية على الأسر المحتاجة',
                'description' => 'نحتاج متطوعين لتوزيع 50 سلة غذائية على الأسر المحتاجة في منطقة مصر الجديدة.',
                'category' => 'مساعدات غذائية',
                'governorate' => 'القاهرة',
                'priority' => 'high',
                'organization_id' => $organization->id,
                'volunteers_needed' => 10,
                'volunteers_applied' => 4,
                'is_urgent' => true,
            ],
            [
                'title' => 'مساعدة في حملة تبرع بالدم',
                'description' => 'نحتاج متطوعين للتسجيل والتنظيم في حملة التبرع بالدم.',
                'category' => 'علاج طبي',
                'governorate' => 'الأقصر',
                'priority' => 'urgent',
                'organization_id' => $organization->id,
                'volunteers_needed' => 6,
                'volunteers_applied' => 2,
                'is_urgent' => true,
            ],
            [
                'title' => 'تدريس الأطفال المحرومين',
                'description' => 'برنامج تعليمي للأطفال في المناطق النائية.',
                'category' => 'تعليم',
                'governorate' => 'المنصورة',
                'priority' => 'medium',
                'organization_id' => $organization->id,
                'volunteers_needed' => 4,
                'volunteers_applied' => 1,
            ],
        ];

        foreach ($opportunities as $opportunity) {
            VolunteerOpportunity::create($opportunity);
        }
    }
}
