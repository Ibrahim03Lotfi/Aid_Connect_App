<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emergency_missions', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->enum('urgency', ['critical', 'high', 'medium'])->default('high');
            $table->json('required_skills')->nullable(); // e.g. ["مسعف", "سائق"]
            $table->foreignId('governorate_id')->constrained('governorates')->onDelete('cascade');
            $table->string('district')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->unsignedSmallInteger('volunteers_needed')->default(1);
            $table->unsignedSmallInteger('volunteers_joined')->default(0);
            $table->enum('status', ['open', 'in_progress', 'completed', 'cancelled'])->default('open');
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });

        Schema::create('mission_volunteers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mission_id')->constrained('emergency_missions')->onDelete('cascade');
            $table->foreignId('volunteer_id')->constrained('users')->onDelete('cascade');
            $table->enum('status', ['joined', 'checked_in', 'completed', 'withdrawn'])->default('joined');
            $table->timestamp('checked_in_at')->nullable();
            $table->timestamps();

            $table->unique(['mission_id', 'volunteer_id']);
        });

        Schema::create('volunteer_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('volunteer_id')->constrained('users')->onDelete('cascade');
            $table->enum('mission_type', ['field_assessment', 'aid_distribution', 'emergency_mission']);
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->decimal('hours_logged', 5, 2)->default(1.00);
            $table->unsignedInteger('points_earned')->default(10);
            $table->string('badge_awarded')->nullable();
            $table->boolean('verified_by_admin')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('volunteer_logs');
        Schema::dropIfExists('mission_volunteers');
        Schema::dropIfExists('emergency_missions');
    }
};
