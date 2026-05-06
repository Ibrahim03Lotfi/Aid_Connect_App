<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class VolunteerOpportunity extends Model
{
    use HasFactory;

    protected $table = 'volunteer_opportunities';

    protected $fillable = [
        'title',
        'description',
        'category',
        'governorate',
        'priority',
        'organization_id',
        'volunteers_needed',
        'volunteers_applied',
        'is_urgent',
        'status',
    ];

    protected $casts = [
        'is_urgent' => 'boolean',
        'volunteers_needed' => 'integer',
        'volunteers_applied' => 'integer',
    ];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(User::class, 'organization_id');
    }

    public function applications(): HasMany
    {
        return $this->hasMany(VolunteerApplication::class, 'opportunity_id');
    }
}
