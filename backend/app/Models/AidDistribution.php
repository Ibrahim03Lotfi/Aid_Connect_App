<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AidDistribution extends Model
{
    use HasFactory;

    protected $fillable = [
        'campaign_id',
        'beneficiary_id',
        'volunteer_id',
        'verification_method',
        'latitude',
        'longitude',
        'photo_proof',
        'distributed_at',
        'is_offline_synced',
        'notes',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'is_offline_synced' => 'boolean',
        'distributed_at' => 'datetime',
    ];

    public function campaign()
    {
        return $this->belongsTo(AidCampaign::class, 'campaign_id');
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
