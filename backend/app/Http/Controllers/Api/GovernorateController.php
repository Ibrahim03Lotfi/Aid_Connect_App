<?php

namespace App\Http\Controllers\Api;

use App\Models\Governorate;

class GovernorateController extends ApiController
{
    public function index()
    {
        $governorates = Governorate::withCount('cases')->get()->map(function ($governorate) {
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
