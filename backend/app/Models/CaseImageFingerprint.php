<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaseImageFingerprint extends Model
{
    use HasFactory;

    protected $fillable = [
        'case_id',
        'image_path',
        'phash',
    ];

    public function case()
    {
        return $this->belongsTo(AidCase::class, 'case_id');
    }
}
