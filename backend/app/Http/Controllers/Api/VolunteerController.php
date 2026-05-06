<?php

namespace App\Http\Controllers\Api;

use App\Models\VolunteerApplication;
use App\Models\VolunteerOpportunity;
use Illuminate\Http\Request;

class VolunteerController extends ApiController
{
    public function availableCases(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $query = VolunteerOpportunity::with('organization')
            ->where('status', 'active');

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        if ($request->has('governorate')) {
            $query->where('governorate', $request->governorate);
        }

        $opportunities = $query->latest()->paginate($request->per_page ?? 10);

        $data = $opportunities->map(function ($op) {
            return [
                'id' => $op->id,
                'title' => $op->title,
                'description' => $op->description,
                'category' => $op->category,
                'governorate' => $op->governorate,
                'priority' => $op->priority,
                'organization_name' => $op->organization?->name,
                'volunteers_needed' => $op->volunteers_needed,
                'volunteers_applied' => $op->volunteers_applied,
                'is_urgent' => $op->is_urgent,
                'created_at' => $op->created_at->toIso8601String(),
            ];
        });

        return $this->paginatedResponse($data, $opportunities);
    }

    public function showCase(Request $request, $id)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $op = VolunteerOpportunity::with('organization')->find($id);

        if (! $op) {
            return $this->errorResponse('Opportunity not found', 404);
        }

        return $this->successResponse([
            'id' => $op->id,
            'title' => $op->title,
            'description' => $op->description,
            'category' => $op->category,
            'governorate' => $op->governorate,
            'priority' => $op->priority,
            'organization_name' => $op->organization?->name,
            'volunteers_needed' => $op->volunteers_needed,
            'volunteers_applied' => $op->volunteers_applied,
            'is_urgent' => $op->is_urgent,
            'created_at' => $op->created_at->toIso8601String(),
        ]);
    }

    public function apply(Request $request, $caseId)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $op = VolunteerOpportunity::find($caseId);

        if (! $op) {
            return $this->errorResponse('Opportunity not found', 404);
        }

        if ($op->volunteers_applied >= $op->volunteers_needed) {
            return $this->errorResponse('No spots available', 422);
        }

        $existing = VolunteerApplication::where('user_id', $request->user()->id)
            ->where('opportunity_id', $caseId)
            ->first();

        if ($existing) {
            return $this->errorResponse('Already applied', 422);
        }

        VolunteerApplication::create([
            'user_id' => $request->user()->id,
            'opportunity_id' => $caseId,
            'case_id' => null,
            'status' => 'pending',
            'case_title' => $op->title,
            'organization_name' => $op->organization?->name,
            'category' => $op->category,
        ]);

        $op->increment('volunteers_applied');

        return $this->successResponse(null, 'Application submitted successfully');
    }

    public function myApplications(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $query = VolunteerApplication::where('user_id', $request->user()->id);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $applications = $query->latest()->paginate($request->per_page ?? 10);

        $data = $applications->map(function ($app) {
            return [
                'id' => $app->id,
                'case_id' => $app->opportunity_id,
                'case_title' => $app->case_title,
                'status' => $app->status,
                'applied_at' => $app->created_at->toIso8601String(),
                'organization_name' => $app->organization_name,
                'category' => $app->category,
            ];
        });

        return $this->paginatedResponse($data, $applications);
    }

    public function cancelApplication(Request $request, $id)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $application = VolunteerApplication::where('user_id', $request->user()->id)->find($id);

        if (! $application) {
            return $this->errorResponse('Application not found', 404);
        }

        $application->opportunity?->decrement('volunteers_applied');
        $application->delete();

        return $this->successResponse(null, 'Application cancelled');
    }

    public function profile(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $user = $request->user();
        $completed = VolunteerApplication::where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();
        $active = VolunteerApplication::where('user_id', $user->id)
            ->whereIn('status', ['pending', 'accepted'])
            ->count();

        return $this->successResponse([
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'bio' => $user->bio ?? '',
            'skills' => $user->skills ?? [],
            'joined_at' => $user->created_at->format('Y'),
            'completed_cases' => $completed,
            'active_cases' => $active,
        ]);
    }

    public function updateProfile(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'bio' => 'sometimes|string',
            'skills' => 'sometimes|array',
        ]);

        $user->update($validated);

        return $this->successResponse(null, 'Profile updated successfully');
    }
}
