<?php

namespace App\Services\Ai;

class ArabicTriageClassifierService
{
    /**
     * Compute humanitarian urgency index (1-100) and triage tier for Arabic case texts.
     *
     * @param string $title
     * @param string $description
     * @param array $context [category_id, governorate_id, family_members, target_amount, etc.]
     * @return array
     */
    public function classifyCase(string $title, string $description, array $context = []): array
    {
        $text = mb_strtolower($title . ' ' . $description, 'UTF-8');
        $score = 20; // baseline

        $vulnerabilityFactors = [];

        // 1. Extreme Critical Medical & Life-Threatening Triggers (+45 to +60)
        $criticalKeywords = [
            'عملية جراحية عاجلة' => 'عملية جراحية عاجلة لإنقاذ الحياة',
            'قلب مفتوح' => 'جراحة قلب مفتوح طارئة',
            'إنعاش' => 'حالة حرجة بحاجة عناية مشددة وإنعاش',
            'سرطان' => 'مريض أورام خبيثة وجرعات علاج كيماوي',
            'غسيل كلى' => 'فشل كلوي واحتياج جلسات ديلزة دموية منتظمة',
            'بتر' => 'خطر بتر طرف أو إصابة حربية بالغة',
            'نزيف' => 'نزيف حاد أو مضاعفات بعد ولادة طارئة',
            'حروق' => 'إصابة بحروق من درجات متقدمة تستلزم مراهم وعناية خاصة',
            'استئصال' => 'جراحة استئصال ورم مستعجلة',
        ];

        foreach ($criticalKeywords as $keyword => $factor) {
            if (str_contains($text, $keyword)) {
                $score += 35;
                $vulnerabilityFactors[] = $factor;
                break;
            }
        }

        // 2. Infant & Child Vulnerabilities (+25)
        $childKeywords = [
            'رضيع' => 'رضيع أو طفل حديث ولادة في خطر صحي داهم',
            'حاضنة' => 'طفل بحاجة حاضنة أطفال وتغذية وريدية',
            'أطفال' => 'أطفال قاصرين مهددين بالحرمان الصحي والغذائي',
            'يتيم' => 'أيتام قاصرين فقدوا المعيل',
            'أيتام' => 'عائلة أيتام تعاني من انعدام الدخل',
            'حليب' => 'انعدام حليب الرضع ومكملات نمو الأطفال',
        ];

        foreach ($childKeywords as $keyword => $factor) {
            if (str_contains($text, $keyword)) {
                $score += 20;
                $vulnerabilityFactors[] = $factor;
                break;
            }
        }

        // 3. Environmental & Winterization Disaster Triggers (+25)
        $winterKeywords = [
            'صقيع' => 'تعرض مباشر لموجات صقيع حادة وخطر انخفاض حرارة الجسم',
            'برد قارس' => 'برد قارس وانعدام تام لوسائل التدفئة والمحروقات',
            'تجمّد' => 'مخاطر التجمّد في المخيمات الشتوية',
            'سيول' => 'غرق الخيمة أو انهيار جدران المأوى بفعل السيول',
            'خيمة' => 'إقامة في مخيمات النزوح المؤقتة العشوائية',
            'مطر' => 'تسرب مياه الأمطار وتلف الأمتعة والمفروشات',
        ];

        foreach ($winterKeywords as $keyword => $factor) {
            if (str_contains($text, $keyword)) {
                $score += 20;
                $vulnerabilityFactors[] = $factor;
                break;
            }
        }

        // 4. Family & Economic Destitution Triggers (+15)
        $destitutionKeywords = [
            'دون معيل' => 'غياب كامل لمعيل الأسرة',
            'عاجز' => 'رب الأسرة يعاني من عجز دائم أو شلل كامل',
            'مسن' => 'مسنون طريحو الفراش دون رعاية كافية',
            'ديون' => 'تراكم ديون علاجية ومطالبات إخلاء سكن',
            'طرد' => 'تهديد مباشر بطرد العائلة من المأوى',
        ];

        foreach ($destitutionKeywords as $keyword => $factor) {
            if (str_contains($text, $keyword)) {
                $score += 15;
                $vulnerabilityFactors[] = $factor;
                break;
            }
        }

        // Target amount scale factor (urgent large interventions)
        $targetAmount = (float)($context['target_amount'] ?? 0);
        if ($targetAmount >= 15000000) {
            $score += 10;
        }

        // Clamp to 1..100
        $score = min(100, max(10, $score));

        // Assign triage tier
        if ($score >= 90) {
            $tier = 'critical';
            $tierLabel = 'طارئ وحرج جداً (تدخل استجابة أولى خلال 24 ساعة)';
            $badgeColor = '#DC2626';
            $priorityAlert = true;
            $recommendedAction = 'إطلاق حملة تبرع عاجلة مع إرسال باحث ميداني خلال 12 ساعة للتأكد المباشر';
        } elseif ($score >= 70) {
            $tier = 'high';
            $tierLabel = 'عالي الأولوية (استجابة خلال 48 ساعة)';
            $badgeColor = '#F59E0B';
            $priorityAlert = true;
            $recommendedAction = 'نشر الحالة في واجهة الحالات العاجلة وتخصيص معونة فورية من المستودع';
        } elseif ($score >= 40) {
            $tier = 'medium';
            $tierLabel = 'أولوية متوسطة (ضمن دورة الدعم الإغاثي الأسبوعي)';
            $badgeColor = '#3B82F6';
            $priorityAlert = false;
            $recommendedAction = 'إدراج الحالة في القائمة المجدولة للدعم والتبرع الاعتيادي';
        } else {
            $tier = 'low';
            $tierLabel = 'اعتيادي (متابعة إرشادية وتنموية)';
            $badgeColor = '#10B981';
            $priorityAlert = false;
            $recommendedAction = 'توجيه الأسرة نحو فرص التدريب المهني أو السلل التموينية الدورية';
        }

        return [
            'urgency_index' => $score,
            'triage_tier' => $tier,
            'tier_label' => $tierLabel,
            'badge_color' => $badgeColor,
            'priority_alert' => $priorityAlert,
            'key_vulnerability_factors' => array_unique($vulnerabilityFactors),
            'recommended_action' => $recommendedAction,
            'analyzed_at' => now()->toIso8601String(),
            'engine' => 'athar_arabic_nlp_triage_v1',
        ];
    }
}
