<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\OrganizationRequest;
use Illuminate\Http\Request;

class OrganizationController extends ApiController
{
    public function myCases(Request $request)
    {
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

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
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

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
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

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
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

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
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

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

    public function dashboard(Request $request)
    {
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

        $myCasesQuery = AidCase::where('organization_id', $request->user()->id);
        $pendingCasesCount = (clone $myCasesQuery)->where('status', 'pending')->count();
        $approvedCasesCount = (clone $myCasesQuery)->where('status', 'approved')->count();
        $rejectedCasesCount = (clone $myCasesQuery)->where('status', 'rejected')->count();
        $totalCasesCount = $myCasesQuery->count();

        // Calculate total donations (sum of views as placeholder for now)
        $totalDonations = $myCasesQuery->sum('views');

        return $this->successResponse([
            'pending_cases_count' => $pendingCasesCount,
            'approved_cases_count' => $approvedCasesCount,
            'rejected_cases_count' => $rejectedCasesCount,
            'total_cases_count' => $totalCasesCount,
            'total_donations' => $totalDonations,
        ]);
    }

    public function profile(Request $request)
    {
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

        $user = $request->user();

        return $this->successResponse([
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'address' => $user->address ?? '',
            'description' => $user->bio ?? '',
            'registration_number' => $user->registration_number ?? '',
            'joined_at' => $user->created_at->format('Y'),
        ]);
    }

    public function updateProfile(Request $request)
    {
        if ($request->user()->role !== 'organization') {
            return $this->errorResponse('Only organizations can access this endpoint', 403);
        }

        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'address' => 'sometimes|string',
            'bio' => 'sometimes|string',
            'registration_number' => 'sometimes|string|max:255',
        ]);

        $user->update($validated);

        return $this->successResponse(null, 'Profile updated successfully');
    }
}
