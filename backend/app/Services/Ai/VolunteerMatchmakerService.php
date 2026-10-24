<?php

namespace App\Services\Ai;

use App\Models\EmergencyMission;
use App\Models\User;

class VolunteerMatchmakerService
{
    /**
     * Match and recommend the top 5 volunteers for an emergency mission.
     *
     * @param EmergencyMission|int $mission
     * @return array
     */
    public function matchVolunteersForMission($mission): array
    {
        if (is_numeric($mission)) {
            $mission = EmergencyMission::with('governorate')->findOrFail($mission);
        }

        $requiredSkills = (array)($mission->required_skills ?? []);
        $targetLat = (float)($mission->latitude ?? 33.5138); // Default Damascus coordinates if unset
        $targetLng = (float)($mission->longitude ?? 36.2765);
        $govId = $mission->governorate_id;

        $volunteers = User::where('role', 'volunteer')
            ->where('is_active', true)
            ->get();

        $scoredVolunteers = [];

        foreach ($volunteers as $vol) {
            $score = 0;
            $matchedSkills = [];

            // 1. Skills Matching (up to 45 points)
            $volSkills = (array)($vol->skills ?? []);
            if (!empty($requiredSkills)) {
                $matched = array_intersect(
                    array_map('mb_strtolower', $requiredSkills),
                    array_map('mb_strtolower', $volSkills)
                );
                $matchedSkills = array_values($matched);
                $skillRatio = count($requiredSkills) > 0 ? count($matched) / count($requiredSkills) : 0.5;
                $score += round($skillRatio * 45);
            } else {
                $score += 30; // default base if no specific skills specified
            }

            // 2. Proximity & Location Matching (up to 35 points)
            $distanceKm = null;
            if ($vol->latitude && $vol->longitude) {
                $distanceKm = $this->calculateHaversineDistance(
                    $targetLat,
                    $targetLng,
                    (float)$vol->latitude,
                    (float)$vol->longitude
                );
                // Proximity points: < 5km = 35pts, < 20km = 28pts, < 50km = 18pts, etc.
                if ($distanceKm <= 5) {
                    $score += 35;
                } elseif ($distanceKm <= 20) {
                    $score += 28;
                } elseif ($distanceKm <= 50) {
                    $score += 18;
                } else {
                    $score += 8;
                }
            } else {
                // Governorate matching fallback
                if ($vol->governorate_id && $vol->governorate_id == $govId) {
                    $score += 30;
                    $distanceKm = 12.0; // approximated within governorate
                } else {
                    $score += 15;
                    $distanceKm = 45.0;
                }
            }

            // 3. Readiness, Rank & Experience (up to 20 points)
            $points = (int)($vol->volunteer_points ?? 0);
            $hours = (float)($vol->volunteer_hours ?? 0);

            if ($points >= 300 || $hours >= 80) {
                $score += 10;
            } elseif ($points >= 100 || $hours >= 30) {
                $score += 7;
            } else {
                $score += 4;
            }

            // Mobility bonus
            if ($vol->has_vehicle) {
                $score += 10;
            }

            // Clamp total score to 100
            $totalScore = min(100, max(20, $score));

            // Generate human-friendly match rationale
            $reason = [];
            if (!empty($matchedSkills)) {
                $reason[] = 'يمتلك المهارات المطلوبة (' . implode('، ', $matchedSkills) . ')';
            }
            if ($distanceKm !== null && $distanceKm <= 15) {
                $reason[] = "قريب جغرافياً من موقع المهمة (~{$distanceKm} كم)";
            }
            if ($vol->has_vehicle) {
                $reason[] = 'يتوفر وسيلة نقل خاصة للاستجابة السريعة';
            }
            if ($hours >= 50) {
                $reason[] = 'خبرة ميدانية موثقة تتجاوز 50 ساعة';
            }

            $scoredVolunteers[] = [
                'volunteer_id' => $vol->id,
                'name' => $vol->name,
                'phone' => $vol->phone,
                'avatar' => $vol->avatar,
                'volunteer_rank' => $vol->volunteer_rank ?? 'متطوع ميداني',
                'volunteer_hours' => $hours,
                'volunteer_points' => $points,
                'has_vehicle' => (bool)$vol->has_vehicle,
                'match_score' => $totalScore,
                'distance_km' => $distanceKm !== null ? round($distanceKm, 1) : null,
                'matched_skills' => $matchedSkills,
                'recommendation_reason' => !empty($reason) ? implode(' • ', $reason) : 'جاهزية عامة للمشاركة الميدانية',
            ];
        }

        // Sort descending by match_score
        usort($scoredVolunteers, fn($a, $b) => $b['match_score'] <=> $a['match_score']);

        // Top 5 recommended volunteers
        $top5 = array_slice($scoredVolunteers, 0, 5);

        // Cache in mission
        $mission->update(['ai_matched_volunteers' => $top5]);

        return [
            'mission_id' => $mission->id,
            'mission_title' => $mission->title,
            'urgency' => $mission->urgency,
            'volunteers_needed' => $mission->volunteers_needed,
            'recommended_volunteers' => $top5,
            'total_candidates_analyzed' => count($scoredVolunteers),
            'matched_at' => now()->toIso8601String(),
        ];
    }

    /**
     * Haversine formula to compute great-circle distance between two GPS coordinates in kilometers.
     */
    protected function calculateHaversineDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
