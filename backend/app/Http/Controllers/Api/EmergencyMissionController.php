<?php

namespace App\Http\Controllers\Api;

use App\Models\EmergencyMission;
use App\Models\MissionVolunteer;
use App\Models\VolunteerLog;
use Illuminate\Http\Request;

class EmergencyMissionController extends ApiController
{
    public function index(Request $request)
    {
        $query = EmergencyMission::with(['governorate', 'creator:id,name']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        } else {
            $query->whereIn('status', ['open', 'in_progress']);
        }

        if ($request->filled('urgency')) {
            $query->where('urgency', $request->urgency);
        }

        $missions = $query->latest()->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($missions->items(), $missions);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'urgency' => 'required|in:critical,high,medium',
            'required_skills' => 'nullable|array',
            'governorate_id' => 'required|exists:governorates,id',
            'district' => 'nullable|string|max:100',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'volunteers_needed' => 'required|integer|min:1',
        ]);

        $mission = EmergencyMission::create([
            ...$validated,
            'volunteers_joined' => 0,
            'status' => 'open',
            'created_by' => $request->user()->id,
        ]);

        return $this->successResponse($mission->load('governorate'), 'تم إطلاق نداء الطوارئ بنجاح');
    }

    public function show($id)
    {
        $mission = EmergencyMission::with(['governorate', 'creator:id,name', 'volunteers'])->find($id);

        if (!$mission) {
            return $this->errorResponse('المهمة غير موجودة', 404);
        }

        return $this->successResponse($mission);
    }

    // Volunteer accepts mission from mobile app
    public function joinMission(Request $request, $id)
    {
        $mission = EmergencyMission::find($id);
        if (!$mission) {
            return $this->errorResponse('المهمة غير موجودة', 404);
        }

        if ($mission->status === 'completed' || $mission->status === 'cancelled') {
            return $this->errorResponse('هذه المهمة مغلقة', 422);
        }

        $volunteer = $request->user();

        $existing = MissionVolunteer::where('mission_id', $mission->id)
            ->where('volunteer_id', $volunteer->id)
            ->first();

        if ($existing) {
            return $this->errorResponse('لقد انضممت إلى هذه المهمة بالفعل', 422);
        }

        if ($mission->volunteers_joined >= $mission->volunteers_needed) {
            return $this->errorResponse('اكتمل العدد المطلوب لهذه المهمة', 422);
        }

        MissionVolunteer::create([
            'mission_id' => $mission->id,
            'volunteer_id' => $volunteer->id,
            'status' => 'joined',
        ]);

        $mission->increment('volunteers_joined');

        return $this->successResponse($mission->fresh(), 'تم انضمامك إلى مهمة الطوارئ بنجاح');
    }

    // Volunteer checks in at the mission site
    public function checkIn(Request $request, $id)
    {
        $volunteer = $request->user();

        $entry = MissionVolunteer::where('mission_id', $id)
            ->where('volunteer_id', $volunteer->id)
            ->first();

        if (!$entry) {
            return $this->errorResponse('أنت لست مسجلاً في هذه المهمة', 404);
        }

        $entry->status = 'checked_in';
        $entry->checked_in_at = now();
        $entry->save();

        // Award emergency response points
        $volunteer->increment('volunteer_points', 50);
        $volunteer->increment('volunteer_hours', 2.0);

        VolunteerLog::create([
            'volunteer_id' => $volunteer->id,
            'mission_type' => 'emergency_mission',
            'reference_id' => $id,
            'hours_logged' => 2.0,
            'points_earned' => 50,
            'badge_awarded' => 'المستجيب السريع',
            'verified_by_admin' => true,
        ]);

        return $this->successResponse($entry, 'تم تسجيل وصولك إلى موقع المهمة بنجاح');
    }

    public function myMissions(Request $request)
    {
        $volunteer = $request->user();

        $missions = EmergencyMission::whereHas('volunteers', function ($q) use ($volunteer) {
            $q->where('volunteer_id', $volunteer->id);
        })
            ->with(['governorate'])
            ->latest()
            ->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($missions->items(), $missions);
    }
}
