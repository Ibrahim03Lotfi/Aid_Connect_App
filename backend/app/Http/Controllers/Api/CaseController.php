<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use Illuminate\Http\Request;

class CaseController extends ApiController
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

    private function resolveUserId(Request $request): ?int
    {
        if ($user = $request->user()) {
            return $user->id;
        }
        if ($plainToken = $request->bearerToken()) {
            $hashedToken = hash('sha256', $plainToken);
            $user = \App\Models\User::where('api_token', $hashedToken)->where('is_active', true)->first();
            if ($user) {
                $request->setUserResolver(fn () => $user);
                return $user->id;
            }
        }
        return null;
    }

    public function index(Request $request)
    {
        $userId = $this->resolveUserId($request);

        $query = AidCase::with(['category', 'governorate', 'organization'])
            ->where('status', 'approved');

        if ($request->has('governorate_id')) {
            $query->where('governorate_id', $request->governorate_id);
        }

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $cases = $query->latest()->paginate($request->per_page ?? 10);

        $data = $cases->map(function ($case) use ($userId) {
            return $this->formatCase($case, $userId);
        });

        return $this->paginatedResponse($data, $cases);
    }

    public function show(Request $request, $id)
    {
        $userId = $this->resolveUserId($request);
        $case = AidCase::with(['category', 'governorate', 'organization', 'attachments', 'images'])->find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        return $this->successResponse($this->formatCase($case, $userId, true));
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

    public function toggleLike(Request $request, $id)
    {
        $case = AidCase::find($id);
        if (!$case) {
            return $this->errorResponse('Case not found', 404);
        }

        $case->increment('likes_count');
        return $this->successResponse(['likes_count' => $case->likes_count], 'Liked successfully');
    }

    public function comments($id)
    {
        $case = AidCase::find($id);
        if (!$case) {
            return $this->errorResponse('Case not found', 404);
        }

        $comments = $case->comments()->with('user:id,name,avatar')->latest()->get()->map(function ($c) {
            return [
                'id' => $c->id,
                'user_name' => $c->user ? $c->user->name : 'فاعل خير',
                'user_avatar' => $c->user ? $c->user->avatar : null,
                'comment' => $c->comment,
                'created_at' => $c->created_at->diffForHumans(),
            ];
        });

        return $this->successResponse($comments);
    }

    public function addComment(Request $request, $id)
    {
        $validated = $request->validate([
            'comment' => 'required|string|max:500',
        ]);

        $case = AidCase::find($id);
        if (!$case) {
            return $this->errorResponse('Case not found', 404);
        }

        $userId = $request->user()?->id ?? \App\Models\User::first()?->id ?? 1;
        $userName = $request->user()?->name ?? 'فاعل خير';

        $comment = $case->comments()->create([
            'user_id' => $userId,
            'comment' => $validated['comment'],
        ]);

        return $this->successResponse([
            'id' => $comment->id,
            'user_name' => $userName,
            'comment' => $comment->comment,
            'created_at' => 'الآن',
        ], 'تمت إضافة التعليق بنجاح');
    }

    // Sham Cash / Syriatel Cash Donation
    public function donate(Request $request, $id)
    {
        $validated = $request->validate([
            'amount' => 'required|numeric|min:1000',
            'payment_method' => 'required|in:sham_cash,syriatel_cash,in_kind',
            'donor_name' => 'nullable|string|max:100',
            'donor_phone' => 'nullable|string|max:20',
        ]);

        $case = AidCase::find($id);
        if (!$case) {
            return $this->errorResponse('Case not found', 404);
        }

        $amount = (float) $validated['amount'];
        $case->increment('collected_amount', $amount);

        $ref = strtoupper($validated['payment_method']) . '-' . rand(100000, 999999);

        $donation = $case->donations()->create([
            'user_id' => $request->user()?->id,
            'amount' => $amount,
            'currency' => 'SYP',
            'payment_method' => $validated['payment_method'],
            'donor_name' => $validated['donor_name'] ?? ($request->user()?->name ?? 'فاعل خير'),
            'donor_phone' => $validated['donor_phone'] ?? $request->user()?->phone,
            'transaction_ref' => $ref,
            'status' => 'completed',
        ]);

        return $this->successResponse([
            'transaction_ref' => $ref,
            'amount' => $amount,
            'currency' => 'ل.س',
            'payment_method_label' => $validated['payment_method'] === 'sham_cash' ? 'شام كاش (Sham Cash)' : 'سيريتل كاش',
            'new_collected_amount' => $case->fresh()->collected_amount,
            'target_amount' => $case->target_amount,
            'progress_percent' => min(100, round(($case->collected_amount / max(1, $case->target_amount)) * 100)),
        ], 'تم استلام تبرعكم بنجاح عبر شام كاش! جزاكم الله خيراً.');
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
            'likes_count' => $case->likes_count ?? 58,
            'comments_count' => $case->comments()->count(),
            'target_amount' => (float) ($case->target_amount ?? 2000000),
            'collected_amount' => (float) ($case->collected_amount ?? 650000),
            'progress_percent' => min(100, round((($case->collected_amount ?? 650000) / max(1, $case->target_amount ?? 2000000)) * 100)),
            'thumbnail' => $this->toAbsoluteUrl($case->thumbnail),
            'created_at' => $case->created_at->toIso8601String(),
            'is_favorited' => $userId ? $case->favorites()->where('user_id', $userId)->exists() : false,
            'organization_name' => $case->organization?->name ?? 'منظمة أثر للإغاثة والتنمية',
            'ai_urgency_index' => $case->ai_urgency_index ?? 75,
            'ai_triage_tier' => $case->ai_triage_tier ?? 'high',
            'ai_vulnerability_factors' => $case->ai_vulnerability_factors ?? [],
            'ai_fraud_status' => $case->ai_fraud_status ?? 'clean',
        ];

        if ($detailed) {
            $data['images'] = $case->images->map(function ($image) {
                return $this->toAbsoluteUrl($image->url);
            })->toArray();
            $data['attachments'] = $case->attachments->map(function ($attachment) {
                return [
                    'id' => $attachment->id,
                    'name' => $attachment->name,
                    'url' => $this->toAbsoluteUrl($attachment->url),
                    'type' => $attachment->type,
                    'size' => $attachment->size,
                ];
            });
        }

        return $data;
    }
}
