<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\OrganizationRequest;
use Illuminate\Http\Request;

class OrganizationController extends ApiController
{
    public function myCases(Request $request)
    {
        $query = AidCase::where('organization_id', $request->user()->id);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $cases = $query->latest()->paginate($request->per_page ?? 10);

        $data = $cases->map(function ($case) {
            return [
                'id' => $case->id,
                'title' => $case->title,
                'description' => $case->description,
                'status' => $case->status,
                'priority' => $case->priority,
                'category' => $case->category?->name,
                'governorate' => $case->governorate?->name,
                'views' => $case->views,
                'donations_count' => 0,
                'created_at' => $case->created_at->toIso8601String(),
                'rejection_reason' => $case->rejection_reason,
            ];
        });

        return $this->paginatedResponse($data, $cases);
    }

    public function show(Request $request, $id)
    {
        $case = AidCase::where('organization_id', $request->user()->id)->find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        return $this->successResponse([
            'id' => $case->id,
            'title' => $case->title,
            'description' => $case->description,
            'status' => $case->status,
            'priority' => $case->priority,
            'category' => $case->category?->name,
            'governorate' => $case->governorate?->name,
            'views' => $case->views,
            'donations_count' => 0,
            'created_at' => $case->created_at->toIso8601String(),
            'rejection_reason' => $case->rejection_reason,
            'images' => $case->images->pluck('url')->toArray(),
            'attachments' => $case->attachments,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'governorate_id' => 'required|exists:governorates,id',
            'priority' => 'required|in:low,medium,high,urgent',
            'images' => 'sometimes|array',
            'attachments' => 'sometimes|array',
        ]);

        $case = AidCase::create([
            ...$validated,
            'organization_id' => $request->user()->id,
            'status' => 'pending',
            'views' => 0,
        ]);

        if ($request->has('images')) {
            foreach ($request->images as $index => $url) {
                $case->images()->create(['url' => $url, 'order' => $index]);
            }
        }

        return $this->successResponse(null, 'Case created successfully');
    }

    public function update(Request $request, $id)
    {
        $case = AidCase::where('organization_id', $request->user()->id)->find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'priority' => 'sometimes|in:low,medium,high,urgent',
            'images' => 'sometimes|array',
        ]);

        $case->update($validated);

        if ($request->has('images')) {
            $case->images()->delete();
            foreach ($request->images as $index => $url) {
                $case->images()->create(['url' => $url, 'order' => $index]);
            }
        }

        return $this->successResponse(null, 'Case updated successfully');
    }

    public function destroy(Request $request, $id)
    {
        $case = AidCase::where('organization_id', $request->user()->id)->find($id);

        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        $case->delete();

        return $this->successResponse(null, 'Case deleted successfully');
    }

    public function submitRequest(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'description' => 'required|string',
            'registration_number' => 'required|string|max:255',
        ]);

        OrganizationRequest::create([
            ...$validated,
            'status' => 'pending',
        ]);

        return $this->successResponse(null, 'Organization request submitted successfully');
    }
}
