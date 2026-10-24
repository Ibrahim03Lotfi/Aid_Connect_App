<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('field_assessments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->nullable()->constrained('cases')->onDelete('set null');
            $table->foreignId('beneficiary_id')->nullable()->constrained('beneficiaries')->onDelete('cascade');
            $table->foreignId('volunteer_id')->constrained('users')->onDelete('cascade');
            $table->unsignedTinyInteger('living_condition_score')->default(5); // 1-10
            $table->string('housing_type')->default('إيجار'); // ملك, إيجار, مأوى مؤقت, هيكل غير مكتمل
            $table->boolean('heating_available')->default(false);
            $table->decimal('monthly_income_estimate', 12, 2)->nullable();
            $table->string('income_source')->nullable();
            $table->enum('urgency_rating', ['normal', 'high', 'critical'])->default('normal');
            $table->json('photos')->nullable();
            $table->text('ai_damage_assessment')->nullable();
            $table->text('inspector_notes');
            $table->enum('status', ['submitted', 'approved', 'rejected'])->default('submitted');
            $table->timestamp('visited_at')->useCurrent();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('field_assessments');
    }
};
