<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VolunteerLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'volunteer_id',
        'mission_type',
        'reference_id',
        'hours_logged',
        'points_earned',
        'badge_awarded',
        'verified_by_admin',
    ];

    protected $casts = [
        'hours_logged' => 'float',
        'points_earned' => 'integer',
        'verified_by_admin' => 'boolean',
    ];

    public function volunteer()
    {
        return $this->belongsTo(User::class, 'volunteer_id');
    }
}
