<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MissionVolunteer extends Model
{
    use HasFactory;

    protected $table = 'mission_volunteers';

    protected $fillable = [
        'mission_id',
        'volunteer_id',
        'status',
        'checked_in_at',
    ];

    protected $casts = [
        'checked_in_at' => 'datetime',
    ];

    public function mission()
    {
        return $this->belongsTo(EmergencyMission::class, 'mission_id');
    }

    public function volunteer()
    {
        return $this->belongsTo(User::class, 'volunteer_id');
    }
}
