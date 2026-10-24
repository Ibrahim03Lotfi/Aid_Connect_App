<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaseDonation extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_id',
        'user_id',
        'amount',
        'currency',
        'payment_method',
        'donor_name',
        'donor_phone',
        'transaction_ref',
        'status',
    ];

    protected $casts = [
        'amount' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function case()
    {
        return $this->belongsTo(AidCase::class, 'case_id');
    }
}
