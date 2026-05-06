<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class AidCase extends Model
{
    use HasFactory;

    protected $table = 'cases';

    protected $fillable = [
        'title',
        'description',
        'status',
        'priority',
        'category_id',
        'governorate_id',
        'organization_id',
        'thumbnail',
        'views',
        'rejection_reason',
    ];

    protected $casts = [
        'views' => 'integer',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function governorate(): BelongsTo
    {
        return $this->belongsTo(Governorate::class);
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(User::class, 'organization_id');
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(CaseAttachment::class, 'case_id');
    }

    public function images(): HasMany
    {
        return $this->hasMany(CaseImage::class, 'case_id');
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class, 'case_id');
    }

    public function volunteerApplications(): HasMany
    {
        return $this->hasMany(VolunteerApplication::class, 'case_id');
    }
}
