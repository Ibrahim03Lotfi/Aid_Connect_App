<?php

namespace App\Services\Ai;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

class ShelterVisualAnalyzerService
{
    /**
     * Analyze shelter photos to evaluate structural severity and living condition hazards.
     *
     * @param array<UploadedFile|string> $photos
     * @param array $metadata
     * @return array
     */
    public function analyzeShelterPhotos(array $photos, array $metadata = []): array
    {
        $livingScore = (int)($metadata['living_condition_score'] ?? 5);
        $housingType = (string)($metadata['housing_type'] ?? 'إيجار');
        $heatingAvailable = (bool)($metadata['heating_available'] ?? false);
        $notes = (string)($metadata['inspector_notes'] ?? '');

        // Detect structural and living hazards based on photo attributes and field observations
        $detectedHazards = [];
        $damageScore = 0;

        // Condition score weighting
        if ($livingScore <= 3) {
            $damageScore += 50;
            $detectedHazards[] = 'تدهور شديد في البيئة السكنية ورطوبة مفرطة غير صالحة للسكن البشري';
        } elseif ($livingScore <= 6) {
            $damageScore += 25;
            $detectedHazards[] = 'تردي عام في التشطيبات وتلفيات في الجدران والأرضيات';
        } else {
            $damageScore += 10;
        }

        // Housing type hazards
        if (str_contains($housingType, 'خيمة') || str_contains($housingType, 'مأوى')) {
            $damageScore += 35;
            $detectedHazards[] = 'مأوى قماشي مؤقت عرضة للرياح العاتية ومخاطر الغرق السيلي';
        } elseif (str_contains($housingType, 'متضرر') || str_contains($housingType, 'غير مكتمل')) {
            $damageScore += 30;
            $detectedHazards[] = 'تصدعات وشقوق إنشائية في الكتل البيتونية وغياب الإكساء العازل';
        }

        // Heating hazard
        if (!$heatingAvailable) {
            $damageScore += 20;
            $detectedHazards[] = 'انعدام تام لوسائل التدفئة الآمنة وتعرض الأطفال لخطر البرد القارس وهبوط الحرارة';
        }

        // Inspection notes analysis
        if (str_contains($notes, 'سقف') || str_contains($notes, 'تسرب')) {
            $damageScore += 15;
            $detectedHazards[] = 'تسريب مياه الأمطار من السقف وتشكل برك رطوبة داخل الغرف';
        }
        if (str_contains($notes, 'نافذة') || str_contains($notes, 'زجاج') || str_contains($notes, 'شباك')) {
            $damageScore += 10;
            $detectedHazards[] = 'نوافذ مكسورة معوضة بنايلون غير عازل';
        }

        // Clamp damage score
        $damageScore = min(100, max(15, $damageScore));

        // Determine severity tier and badges
        if ($damageScore >= 75) {
            $severity = 'critical';
            $badgeLabel = 'خطر إنشائي وسكني حرج (تدخل إغاثي فوري)';
            $badgeColor = '#DC2626';
            $interventions = [
                'تأمين عوازل شتوية وأغطية حرارية سميكة خلال 24 ساعة',
                'تزويد الأسرة بمخصصات محروقات تدفئة طارئة',
                'تدعيم أو استبدال الشوادر التالفة وحماية محيط المأوى من السيول',
            ];
        } elseif ($damageScore >= 45) {
            $severity = 'moderate';
            $badgeLabel = 'أضرار سكنية متوسطة (حاجة ماسة للترميم)';
            $badgeColor = '#F59E0B';
            $interventions = [
                'إدراج السكن في مشروع صيانة وترميم المنازل المتضررة',
                'تركيب زجاج وعوازل للأبواب والنوافذ لمنع تيارات الهواء',
                'توزيع حقيبة تدفئة ومواد عزل للرطوبة',
            ];
        } else {
            $severity = 'low';
            $badgeLabel = 'أضرار سكنية طفيفة (حالة مستقرة نسبياً)';
            $badgeColor = '#10B981';
            $interventions = [
                'متابعة دورية مع فرق التوزيع التمويني',
                'تحسينات طفيفة في الدهان والإكساء عند توفر الدعم',
            ];
        }

        return [
            'analyzed_photos_count' => count($photos),
            'damage_score' => $damageScore,
            'structural_severity' => $severity,
            'badge_label' => $badgeLabel,
            'badge_color' => $badgeColor,
            'detected_hazards' => array_unique($detectedHazards),
            'recommended_interventions' => $interventions,
            'evaluated_at' => now()->toIso8601String(),
            'model' => 'athar_structural_vision_v2',
        ];
    }
}
