<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Beneficiary extends Model
{
    use HasFactory;

    protected $fillable = [
        'full_name',
        'national_id',
        'phone',
        'family_members_count',
        'governorate_id',
        'district',
        'address_details',
        'latitude',
        'longitude',
        'vulnerability_score',
        'nfc_card_uid',
        'qr_token',
        'status',
        'notes',
    ];

    protected $casts = [
        'family_members_count' => 'integer',
        'vulnerability_score' => 'integer',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    protected $appends = [
        'head_of_family_name',
    ];

    public function getHeadOfFamilyNameAttribute()
    {
        return $this->full_name;
    }

    public function governorate()
    {
        return $this->belongsTo(Governorate::class);
    }

    public function nfcCards()
    {
        return $this->hasMany(NfcCard::class);
    }

    public function nfcCard()
    {
        return $this->hasOne(NfcCard::class)->latestOfMany();
    }

    public function activeNfcCard()
    {
        return $this->hasOne(NfcCard::class)->where('is_active', true);
    }

    public function distributions()
    {
        return $this->hasMany(AidDistribution::class);
    }

    public function fieldAssessments()
    {
        return $this->hasMany(FieldAssessment::class);
    }
}
