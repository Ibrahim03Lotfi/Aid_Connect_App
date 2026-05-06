<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\VolunteerApplication;
use App\Models\VolunteerOpportunity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class VolunteerController extends ApiController
{
    public function dashboard(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $myCasesQuery = AidCase::where('organization_id', $request->user()->id);
        $myPostedCasesCount = (clone $myCasesQuery)->count();

        $allVolunteerCasesCount = AidCase::whereHas('organization', function ($q) {
            $q->where('role', 'volunteer');
        })->count();

        return $this->successResponse([
            'my_posted_cases_count' => $myPostedCasesCount,
            'all_volunteer_cases_count' => $allVolunteerCasesCount,
        ]);
    }

    // Volunteer searchable feed of approved cases posted by volunteers (random order)
    public function volunteerCasesFeed(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $query = AidCase::with(['category', 'governorate', 'organization'])
            ->where('status', 'approved')
            ->whereHas('organization', function ($q) {
                $q->where('role', 'volunteer');
            });

        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($sub) use ($q) {
                $sub->where('title', 'like', "%{$q}%")
                    ->orWhereHas('organization', function ($org) use ($q) {
                        $org->where('name', 'like', "%{$q}%");
                    })
                    ->orWhereHas('governorate', function ($gov) use ($q) {
                        $gov->where('name', 'like', "%{$q}%");
                    });
            });
        }

        $cases = $query->inRandomOrder()->paginate($request->per_page ?? 10);
        $data = $cases->map(function ($case) use ($request) {
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
                'organization_name' => $case->organization?->name,
                'is_favorited' => false,
            ];
        });

        return $this->paginatedResponse($data, $cases);
    }

    // Volunteer-owned aid cases (CRUD like organization)
    public function myAidCases(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
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

    public function storeAidCase(Request $request)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'governorate_id' => 'required|exists:governorates,id',
            'priority' => 'required|in:low,medium,high,urgent',
            'attachments' => 'sometimes|array',
            'images' => 'sometimes|array',
            'images.*' => 'image|max:5120',
        ]);

        $case = AidCase::create([
            ...collect($validated)->except(['images'])->toArray(),
            'organization_id' => $request->user()->id,
            'status' => 'pending',
            'views' => 0,
        ]);

        if ($request->hasFile('images')) {
            $urls = [];
            foreach ($request->file('images') as $index => $file) {
                $path = $file->store('case-images', 'public');
                $url = Storage::url($path);
                $urls[] = $url;
                $case->images()->create(['url' => $url, 'order' => $index]);
            }
            if (! empty($urls)) {
                $case->thumbnail = $urls[0];
                $case->save();
            }
        }

        return $this->successResponse(null, 'Case created successfully');
    }

    public function updateAidCase(Request $request, $id)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
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
            'images.*' => 'image|max:5120',
        ]);

        $case->update(collect($validated)->except(['images'])->toArray());

        if ($request->hasFile('images')) {
            $case->images()->delete();
            $urls = [];
            foreach ($request->file('images') as $index => $file) {
                $path = $file->store('case-images', 'public');
                $url = Storage::url($path);
                $urls[] = $url;
                $case->images()->create(['url' => $url, 'order' => $index]);
            }
            if (! empty($urls)) {
                $case->thumbnail = $urls[0];
                $case->save();
            }
        }

        return $this->successResponse(null, 'Case updated successfully');
    }

    public function destroyAidCase(Request $request, $id)
    {
        if ($request->user()->role !== 'volunteer') {
            return $this->errorResponse('Only volunteers can access this endpoint', 403);
        }

        $case = AidCase::where('organization_id', $request->user()->id)->find($id);
        if (! $case) {
            return $this->errorResponse('Case not found', 404);
        }

        $case->delete();
        return $this->successResponse(null, 'Case deleted successfully');
    }

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
