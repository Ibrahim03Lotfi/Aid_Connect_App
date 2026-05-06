<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('volunteer_opportunities', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->string('category');
            $table->string('governorate');
            $table->string('priority')->default('medium');
            $table->foreignId('organization_id')->constrained('users')->onDelete('cascade');
            $table->unsignedInteger('volunteers_needed')->default(1);
            $table->unsignedInteger('volunteers_applied')->default(0);
            $table->boolean('is_urgent')->default(false);
            $table->string('status')->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('volunteer_opportunities');
    }
};
