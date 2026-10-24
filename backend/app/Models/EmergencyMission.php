<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmergencyMission extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'urgency',
        'required_skills',
        'governorate_id',
        'district',
        'latitude',
        'longitude',
        'volunteers_needed',
        'volunteers_joined',
        'status',
        'created_by',
    ];

    protected $casts = [
        'required_skills' => 'array',
        'latitude' => 'float',
        'longitude' => 'float',
        'volunteers_needed' => 'integer',
        'volunteers_joined' => 'integer',
    ];

    public function governorate()
    {
        return $this->belongsTo(Governorate::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function volunteers()
    {
        return $this->belongsToMany(User::class, 'mission_volunteers', 'mission_id', 'volunteer_id')
            ->withPivot(['status', 'checked_in_at'])
            ->withTimestamps();
    }
}
