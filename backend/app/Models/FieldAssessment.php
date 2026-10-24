<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FieldAssessment extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_id',
        'beneficiary_id',
        'volunteer_id',
        'living_condition_score',
        'housing_type',
        'heating_available',
        'monthly_income_estimate',
        'income_source',
        'urgency_rating',
        'photos',
        'ai_damage_assessment',
        'inspector_notes',
        'status',
        'visited_at',
    ];

    protected $casts = [
        'living_condition_score' => 'integer',
        'heating_available' => 'boolean',
        'monthly_income_estimate' => 'float',
        'photos' => 'array',
        'visited_at' => 'datetime',
    ];

    public function case()
    {
        return $this->belongsTo(AidCase::class, 'case_id');
    }

    public function beneficiary()
    {
        return $this->belongsTo(Beneficiary::class, 'beneficiary_id');
    }

    public function volunteer()
    {
        return $this->belongsTo(User::class, 'volunteer_id');
    }
}
