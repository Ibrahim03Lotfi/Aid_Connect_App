<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CaseImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_id',
        'url',
        'order',
    ];

    public function case(): BelongsTo
    {
        return $this->belongsTo(AidCase::class, 'case_id');
    }
}
