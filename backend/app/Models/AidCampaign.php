<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AidCampaign extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'category_id',
        'start_date',
        'end_date',
        'status',
        'item_type',
        'items_allocated_per_family',
        'target_families_count',
        'distributed_families_count',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'items_allocated_per_family' => 'integer',
        'target_families_count' => 'integer',
        'distributed_families_count' => 'integer',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function distributions()
    {
        return $this->hasMany(AidDistribution::class, 'campaign_id');
    }
}
