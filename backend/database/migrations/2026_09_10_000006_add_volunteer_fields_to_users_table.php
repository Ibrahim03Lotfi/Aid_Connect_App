<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('volunteer_rank')->default('متطوع ميداني')->nullable();
            $table->unsignedInteger('volunteer_points')->default(0);
            $table->decimal('volunteer_hours', 6, 2)->default(0.00);
            $table->json('badges')->nullable();
            $table->boolean('has_vehicle')->default(false);
            $table->string('availability_time')->nullable(); // e.g. "عطلة نهاية الأسبوع", "مسائي", "متفرغ"
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'volunteer_rank',
                'volunteer_points',
                'volunteer_hours',
                'badges',
                'has_vehicle',
                'availability_time',
            ]);
        });
    }
};
