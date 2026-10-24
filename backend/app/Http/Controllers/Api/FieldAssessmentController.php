<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\Beneficiary;
use App\Models\FieldAssessment;
use App\Models\VolunteerLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FieldAssessmentController extends ApiController
{
    public function index(Request $request)
    {
        $query = FieldAssessment::with([
            'volunteer:id,name,phone',
            'beneficiary:id,full_name,national_id,phone,governorate_id',
            'case:id,title,status',
        ]);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('urgency_rating')) {
            $query->where('urgency_rating', $request->urgency_rating);
        }

        $assessments = $query->latest()->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($assessments->items(), $assessments);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'case_id' => 'nullable|exists:cases,id',
            'beneficiary_id' => 'nullable|exists:beneficiaries,id',
            'living_condition_score' => 'required|integer|min:1|max:10',
            'housing_type' => 'required|string|max:100',
            'heating_available' => 'required|boolean',
            'monthly_income_estimate' => 'nullable|numeric',
            'income_source' => 'nullable|string|max:255',
            'urgency_rating' => 'required|in:normal,high,critical',
            'inspector_notes' => 'required|string',
            'photos' => 'nullable|array',
            'photos.*' => 'image|max:10240', // up to 10MB per photo
        ]);

        $volunteer = $request->user();

        // Handle uploaded assessment photos
        $photoUrls = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store('assessments', 'public');
                $photoUrls[] = Storage::url($path);
            }
        }

        $assessment = FieldAssessment::create([
            'case_id' => $validated['case_id'] ?? null,
            'beneficiary_id' => $validated['beneficiary_id'] ?? null,
            'volunteer_id' => $volunteer->id,
            'living_condition_score' => $validated['living_condition_score'],
            'housing_type' => $validated['housing_type'],
            'heating_available' => $validated['heating_available'],
            'monthly_income_estimate' => $validated['monthly_income_estimate'] ?? null,
            'income_source' => $validated['income_source'] ?? null,
            'urgency_rating' => $validated['urgency_rating'],
            'photos' => $photoUrls,
            'inspector_notes' => $validated['inspector_notes'],
            'status' => 'submitted',
            'visited_at' => now(),
        ]);

        // Reward volunteer with 30 points and 1.5 hours
        $volunteer->increment('volunteer_points', 30);
        $volunteer->increment('volunteer_hours', 1.5);

        VolunteerLog::create([
            'volunteer_id' => $volunteer->id,
            'mission_type' => 'field_assessment',
            'reference_id' => $assessment->id,
            'hours_logged' => 1.5,
            'points_earned' => 30,
            'verified_by_admin' => true,
        ]);

        return $this->successResponse($assessment, 'تم رفع تقرير الكشف الميداني بنجاح');
    }

    public function show($id)
    {
        $assessment = FieldAssessment::with([
            'volunteer',
            'beneficiary.governorate',
            'case.category',
            'case.governorate',
        ])->find($id);

        if (!$assessment) {
            return $this->errorResponse('تقرير الكشف غير موجود', 404);
        }

        return $this->successResponse($assessment);
    }

    // Admin approval endpoint
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:approved,rejected',
        ]);

        $assessment = FieldAssessment::find($id);
        if (!$assessment) {
            return $this->errorResponse('تقرير الكشف غير موجود', 404);
        }

        $assessment->status = $validated['status'];
        $assessment->save();

        // If approved and linked to a case, mark the case as approved
        if ($validated['status'] === 'approved' && $assessment->case_id) {
            AidCase::where('id', $assessment->case_id)->update(['status' => 'approved']);
        }

        return $this->successResponse($assessment, 'تم تحديث حالة تقرير الكشف');
    }
}
