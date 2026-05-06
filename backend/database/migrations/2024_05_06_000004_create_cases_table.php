<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cases', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');
            $table->foreignId('governorate_id')->constrained('governorates')->onDelete('cascade');
            $table->foreignId('organization_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('status')->default('pending');
            $table->string('priority')->default('medium');
            $table->string('thumbnail')->nullable();
            $table->unsignedInteger('views')->default(0);
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cases');
    }
};
