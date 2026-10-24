<?php

namespace Database\Seeders;

use App\Models\AidCase;
use App\Models\CaseComment;
use App\Models\CaseDonation;
use App\Models\Category;
use App\Models\Governorate;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RealSyrianCasesSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Clean out bogus / test cases
        AidCase::where('title', 'like', '%حالة جديدة%')
            ->orWhere('title', 'like', '%test%')
            ->orWhere('description', 'like', '%حالة حالة%')
            ->delete();

        // 2. Fetch or create the primary organization: منظمة أثر للإغاثة والتنمية
        $atharOrg = User::where('email', 'info@athar-ngo.sy')->first();
        if (!$atharOrg) {
            $atharOrg = User::firstOrCreate(
                ['email' => 'athar@athar-syria.org'],
                [
                    'name' => 'منظمة أثر للإغاثة والتنمية',
                    'phone' => '0112345678',
                    'password' => bcrypt('password123'),
                    'role' => 'organization',
                    'is_active' => true,
                ]
            );
        } else {
            $atharOrg->update(['name' => 'منظمة أثر للإغاثة والتنمية']);
        }

        // 3. Ensure categories exist
        $medicalCat = Category::firstOrCreate(['name' => 'علاج طبي'], ['icon' => 'medical']);
        $foodCat = Category::firstOrCreate(['name' => 'مساعدات غذائية'], ['icon' => 'food']);
        $shelterCat = Category::firstOrCreate(['name' => 'سكن'], ['icon' => 'housing']);
        $orphansCat = Category::firstOrCreate(['name' => 'كفالة أيتام'], ['icon' => 'finance']);
        $educationCat = Category::firstOrCreate(['name' => 'تعليم'], ['icon' => 'education']);

        // 4. Ensure Syrian Governorates exist
        $damascus = Governorate::firstOrCreate(['name' => 'دمشق']);
        $ruralDamascus = Governorate::firstOrCreate(['name' => 'ريف دمشق']);
        $aleppo = Governorate::firstOrCreate(['name' => 'حلب']);
        $homs = Governorate::firstOrCreate(['name' => 'حمص']);
        $daraa = Governorate::firstOrCreate(['name' => 'درعا']);

        // 5. Real-life humanitarian Syrian cases
        $casesData = [
            [
                'title' => 'عملية قلب مفتوح مستعجلة للطفل عمر (4 سنوات)',
                'description' => 'يعاني الطفل عمر من تشوه خلقي في القلب (رباعي فالوت) مع نوبات زرقة حادة وتراجع بالوزن. يحتاج لعملية تصنيع قلب جراحي مستعجلة بمشفى المواساة بدمشق وتأمين رقعة غشاء التامور ومستلزمات العناية المشددة. تم توثيق وضعه الميداني والتقييم الأسري بواسطة فريق أثر.',
                'governorate_id' => $damascus->id,
                'category_id' => $medicalCat->id,
                'priority' => 'urgent',
                'status' => 'approved',
                'target_amount' => 14500000.0,
                'collected_amount' => 10850000.0,
                'likes_count' => 184,
                'views' => 640,
                'thumbnail' => 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=800',
                'comments' => [
                    ['name' => 'د. حسام المصري', 'comment' => 'تم استلام التقرير الطبي بمشفى المواساة، الحالة مستحقة وندعو الجميع للمساهمة لتحديد موعد العملية سريعاً.'],
                    ['name' => 'سارة الخطيب', 'comment' => 'تم التبرع بمبلغ 100,000 ل.س عبر شام كاش، أسأل الله للطفل الشفاء التام.'],
                    ['name' => 'فريق أثر الميداني', 'comment' => 'تم ربط ملف العائلة بنظام البطاقة الذكية NFC لضمان المتابعة الصحية الدورية بعد العملية.'],
                ],
            ],
            [
                'title' => 'ترميم سقف وعزل شتوي لأسرة أم خالد وأطفالها الخمسة',
                'description' => 'أم خالد أرملة تعيل 5 أطفال في ريف حلب. تعرض منزلهم المتواضع لأضرار بالغة في السقف وتسرب مياه الأمطار الشتوية الشديدة مما أدى لتلف الأفرشة. يتضمن المشروع تركيب عوازل حرارية، صب السقف، وتأمين مازوت التدفئة والبطانيات الصوفية.',
                'governorate_id' => $aleppo->id,
                'category_id' => $shelterCat->id,
                'priority' => 'high',
                'status' => 'approved',
                'target_amount' => 8200000.0,
                'collected_amount' => 6100000.0,
                'likes_count' => 142,
                'views' => 490,
                'thumbnail' => 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=800',
                'comments' => [
                    ['name' => 'م. أنس الحلبي', 'comment' => 'أشرفنا ميدانياً على معاينة المنزل والتقدير الهندسي للمواد، العمل سيبدأ فور اكتمال التمويل بإذن الله.'],
                    ['name' => 'فاعل خير', 'comment' => 'جزاكم الله كل خير، تم التبرع عبر شام كاش.'],
                ],
            ],
            [
                'title' => 'طرف صناعي ذكي وتأهيل فيزيائي للشاب محمد (22 سنة)',
                'description' => 'فقد الشاب محمد طرفه السفلي الأيمن ويحتاج لطرف صناعي خفيف الوزن بتقنية حديثة، مع برنامج تأهيل فيزيائي لـ 24 جلسة لتمكينه من استعادة القدرة على المشي والعودة لعمله ودراسته الجامعية لإعالة والدته المسنة.',
                'governorate_id' => $homs->id,
                'category_id' => $medicalCat->id,
                'priority' => 'high',
                'status' => 'approved',
                'target_amount' => 16000000.0,
                'collected_amount' => 12400000.0,
                'likes_count' => 267,
                'views' => 820,
                'thumbnail' => 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
                'comments' => [
                    ['name' => 'أحمد النجار', 'comment' => 'محمد شاب مكافح وصبور، مساهمتكم تعيد له الأمل في مستقبله وحياته.'],
                    ['name' => 'ريما الحمصي', 'comment' => 'تم التبرع عبر سيريتل كاش، بارك الله في جهود منظمة أثر.'],
                ],
            ],
            [
                'title' => 'كفالة تعليمية وحقائب مدرسية لـ 15 طفلاً يتيماً في الغوطة',
                'description' => 'تأمين الكفالة الدراسية الشاملة، الحقائب والمستلزمات المدرسية، والكتب لـ 15 طفلاً يتيماً في بلدات الغوطة الشرقية لضمان عدم تسربهم من المدارس مع توفير وجبة إفطار مدرسية صحية يومية طيلة الفصل الدراسي.',
                'governorate_id' => $ruralDamascus->id,
                'category_id' => $orphansCat->id,
                'priority' => 'medium',
                'status' => 'approved',
                'target_amount' => 6500000.0,
                'collected_amount' => 5200000.0,
                'likes_count' => 195,
                'views' => 510,
                'thumbnail' => 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800',
                'comments' => [
                    ['name' => 'هدى الصالح', 'comment' => 'التعليم هو النور الحقيقي للأيتام، جزاكم الله خيراً على رعايتهم.'],
                ],
            ],
            [
                'title' => 'سلال غذائية متكاملة وحليب رضع لـ 40 أسرة في درعا',
                'description' => 'توزيع سلال غذائية متكاملة تحتوي على المواد الأساسية (أرز، زيت، سكر، بقوليات، معلبات) بالإضافة إلى عبوات حليب الرضع والمكملات الغذائية للأسر الأشد هشاشة التي ترعى أطفالاً رضعاً وكبار سن في محافظة درعا.',
                'governorate_id' => $daraa->id,
                'category_id' => $foodCat->id,
                'priority' => 'high',
                'status' => 'approved',
                'target_amount' => 9800000.0,
                'collected_amount' => 7650000.0,
                'likes_count' => 220,
                'views' => 730,
                'thumbnail' => 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
                'comments' => [
                    ['name' => 'قاسم الدرعاوي', 'comment' => 'تم التوزيع الميداني بالتنسيق مع المتطوعين والتحقق عبر البطاقة الذكية NFC.'],
                    ['name' => 'فاعل خير', 'comment' => 'تم التبرع بمبلغ 50,000 ل.س عبر شام كاش.'],
                ],
            ],
        ];

        // Also clean out all old cases to ensure the feed is completely pristine
        DB::table('cases')->delete();

        $defaultUser = User::first();

        foreach ($casesData as $data) {
            $comments = $data['comments'];
            unset($data['comments']);

            $data['organization_id'] = $atharOrg->id;
            $data['created_at'] = now()->subHours(rand(1, 48));
            $data['updated_at'] = now();

            $case = AidCase::create($data);

            // Add real comments
            foreach ($comments as $c) {
                $case->comments()->create([
                    'user_id' => $defaultUser->id,
                    'comment' => $c['comment'],
                    'created_at' => now()->subMinutes(rand(5, 120)),
                ]);
            }

            // Seed realistic Syrian donations
            $case->donations()->create([
                'user_id' => $defaultUser->id,
                'amount' => 50000,
                'currency' => 'SYP',
                'payment_method' => 'sham_cash',
                'donor_name' => 'فاعل خير',
                'transaction_ref' => 'SHAM_CASH-' . rand(100000, 999999),
                'status' => 'completed',
            ]);
        }
    }
}
