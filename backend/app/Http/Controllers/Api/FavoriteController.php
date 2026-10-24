<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends ApiController
{
    private function toAbsoluteUrl(?string $path): ?string
    {
        if (! $path) {
            return $path;
        }
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }
        $normalizedPath = str_starts_with($path, '/') ? $path : '/'.$path;
        return request()->getSchemeAndHttpHost().$normalizedPath;
    }

    public function index(Request $request)
    {
        $favorites = Favorite::with(['case.category', 'case.governorate', 'case.organization'])
            ->where('user_id', $request->user()->id)
            ->whereHas('case')
            ->latest()
            ->get();

        $data = $favorites->map(function ($favorite) {
            $case = $favorite->case;
            $target = (float) ($case->target_amount ?? 2000000);
            $collected = (float) ($case->collected_amount ?? 650000);
            $percent = min(100, round(($collected / max(1, $target)) * 100));

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
                'likes_count' => $case->likes_count ?? 54,
                'comments_count' => $case->comments()->count(),
                'target_amount' => $target,
                'collected_amount' => $collected,
                'progress_percent' => $percent,
                'thumbnail' => $this->toAbsoluteUrl($case->thumbnail),
                'created_at' => $case->created_at->toIso8601String(),
                'is_favorited' => true,
                'organization_name' => $case->organization?->name ?? 'منظمة أثر للإغاثة والتنمية',
            ];
        });

        return $this->successResponse($data);
    }

    public function store(Request $request)
    {
        $caseId = $request->input('case_id') ?? $request->input('id');

        if (!$caseId || !AidCase::where('id', $caseId)->exists()) {
            return $this->errorResponse('الحالة غير موجودة', 404);
        }

        Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'case_id' => $caseId,
        ]);

        return $this->successResponse(['is_favorited' => true], 'تمت إضافة الحالة إلى المفضلة بنجاح');
    }

    public function destroy(Request $request, $caseId)
    {
        Favorite::where('user_id', $request->user()->id)
            ->where('case_id', $caseId)
            ->delete();

        return $this->successResponse(['is_favorited' => false], 'تمت إزالة الحالة من المفضلة بنجاح');
    }
}
