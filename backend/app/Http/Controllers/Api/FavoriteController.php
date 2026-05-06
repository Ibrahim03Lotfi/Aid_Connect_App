<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends ApiController
{
    public function index(Request $request)
    {
        $favorites = Favorite::with(['case.category', 'case.governorate'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        $data = $favorites->map(function ($favorite) {
            $case = $favorite->case;
            return [
                'id' => $case->id,
                'title' => $case->title,
                'description' => $case->description,
                'status' => $case->status,
                'priority' => $case->priority,
                'category_id' => $case->category_id,
                'category' => $case->category?->name,
                'governorate_id' => $case->governorate_id,
                'governorate' => $case->governorate?->name,
                'views' => $case->views,
                'thumbnail' => $case->thumbnail,
                'created_at' => $case->created_at->toIso8601String(),
                'is_favorited' => true,
                'organization_name' => $case->organization?->name,
            ];
        });

        return $this->successResponse($data);
    }

    public function store(Request $request)
    {
        $request->validate([
            'case_id' => 'required|exists:cases,id',
        ]);

        Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'case_id' => $request->case_id,
        ]);

        return $this->successResponse(null, 'Added to favorites');
    }

    public function destroy(Request $request, $caseId)
    {
        Favorite::where('user_id', $request->user()->id)
            ->where('case_id', $caseId)
            ->delete();

        return $this->successResponse(null, 'Removed from favorites');
    }
}
