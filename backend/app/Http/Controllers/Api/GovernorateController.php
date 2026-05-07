<?php

namespace App\Http\Controllers\Api;

use App\Models\Governorate;

class GovernorateController extends ApiController
{
    public function index()
    {
        $syrianNames = [
            'دمشق',
            'ريف دمشق',
            'حلب',
            'حمص',
            'حماة',
            'اللاذقية',
            'طرطوس',
            'إدلب',
            'الرقة',
            'دير الزور',
            'الحسكة',
            'درعا',
            'السويداء',
            'القنيطرة',
        ];

        $baseQuery = Governorate::withCount('cases');

        $syrianOnly = (clone $baseQuery)
            ->whereIn('name', $syrianNames)
            ->orderBy('name')
            ->get()
            ->map(function ($governorate) {
                return [
                    'id' => $governorate->id,
                    'name' => $governorate->name,
                    'code' => $governorate->code,
                    'cases_count' => $governorate->cases_count,
                ];
            });

        // Fallback so dropdown never becomes empty if seed data differs.
        $governorates = $syrianOnly->isNotEmpty()
            ? $syrianOnly
            : $baseQuery->orderBy('name')->get()->map(function ($governorate) {
                return [
                    'id' => $governorate->id,
                    'name' => $governorate->name,
                    'code' => $governorate->code,
                    'cases_count' => $governorate->cases_count,
                ];
            });

        return $this->successResponse($governorates);
    }
}
