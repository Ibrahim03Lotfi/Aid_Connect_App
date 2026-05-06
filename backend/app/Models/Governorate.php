<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Governorate extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'code'];

    public function cases(): HasMany
    {
        return $this->hasMany(AidCase::class);
    }

    public function getCasesCountAttribute(): int
    {
        return $this->cases()->count();
    }
}
