<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use Illuminate\Http\Request;

class CaseController extends ApiController
{
    public function index(Request $request)
    {
        $query = AidCase::with(['category', 'governorate', 'organization'])
            ->where('status', 'approved');

        if ($request->has('governorate_id')) {
            $query->where('governorate_id', $request->governorate_id);
        }

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $cases = $query->latest()->paginate($request->per_page ?? 10);

        $data = $cases->map(function ($case) use ($request) {
            return $this->formatCase($case, $request->user()?->id);
        });

        return $this->paginatedResponse($data, $cases);
    }

    public function show(Request $request, $id)
    {
        $case = AidCase::with(['category', 'governorate', 'organization', 'attachments', 'images'])->find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        return $this->successResponse($this->formatCase($case, $request->user()?->id, true));
    }

    public function incrementViews($id)
    {
        $case = AidCase::find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        $case->increment('views');

        return $this->successResponse(null, 'Views incremented');
    }

    private function formatCase(AidCase $case, ?int $userId = null, bool $detailed = false): array
    {
        $data = [
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
            'is_favorited' => $userId ? $case->favorites()->where('user_id', $userId)->exists() : false,
            'organization_name' => $case->organization?->name,
        ];

        if ($detailed) {
            $data['images'] = $case->images->pluck('url')->toArray();
            $data['attachments'] = $case->attachments->map(function ($attachment) {
                return [
                    'id' => $attachment->id,
                    'name' => $attachment->name,
                    'url' => $attachment->url,
                    'type' => $attachment->type,
                    'size' => $attachment->size,
                ];
            });
        }

        return $data;
    }
}
