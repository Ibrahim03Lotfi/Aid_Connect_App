<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'avatar',
        'bio',
        'skills',
        'is_active',
        'api_token',
        'address',
        'registration_number',
        'volunteer_rank',
        'volunteer_points',
        'volunteer_hours',
        'badges',
        'has_vehicle',
        'availability_time',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'api_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'skills' => 'array',
            'badges' => 'array',
            'has_vehicle' => 'boolean',
            'volunteer_hours' => 'float',
            'volunteer_points' => 'integer',
        ];
    }

    public function cases()
    {
        return $this->hasMany(AidCase::class, 'organization_id');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function volunteerApplications()
    {
        return $this->hasMany(VolunteerApplication::class);
    }

    public function fieldAssessments()
    {
        return $this->hasMany(FieldAssessment::class, 'volunteer_id');
    }

    public function aidDistributions()
    {
        return $this->hasMany(AidDistribution::class, 'volunteer_id');
    }

    public function emergencyMissions()
    {
        return $this->belongsToMany(EmergencyMission::class, 'mission_volunteers', 'volunteer_id', 'mission_id')
            ->withPivot(['status', 'checked_in_at'])
            ->withTimestamps();
    }

    public function volunteerLogs()
    {
        return $this->hasMany(VolunteerLog::class, 'volunteer_id');
    }
}
