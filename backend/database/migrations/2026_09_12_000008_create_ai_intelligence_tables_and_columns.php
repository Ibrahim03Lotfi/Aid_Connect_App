<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add AI metadata columns to cases table
        Schema::table('cases', function (Blueprint $table) {
            $table->unsignedSmallInteger('ai_urgency_index')->nullable()->after('priority');
            $table->string('ai_triage_tier')->nullable()->after('ai_urgency_index'); // critical, high, medium, low
            $table->json('ai_vulnerability_factors')->nullable()->after('ai_triage_tier');
            $table->json('ai_invoice_data')->nullable()->after('ai_vulnerability_factors');
            $table->string('ai_fraud_status')->default('clean')->after('ai_invoice_data'); // clean, flagged_duplicate
            $table->foreignId('duplicate_case_id')->nullable()->constrained('cases')->onDelete('set null')->after('ai_fraud_status');
        });

        // Create table for Perceptual Image Fingerprinting (pHash / dHash)
        Schema::create('case_image_fingerprints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->nullable()->constrained('cases')->onDelete('cascade');
            $table->string('image_path');
            $table->string('phash', 64)->index();
            $table->timestamps();
        });

        // Add GPS coordinates to users for volunteer matchmaker proximity
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('latitude', 10, 7)->nullable()->after('address');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            $table->foreignId('governorate_id')->nullable()->constrained('governorates')->onDelete('set null')->after('longitude');
        });

        // Add AI volunteer recommendation cache to emergency missions
        Schema::table('emergency_missions', function (Blueprint $table) {
            $table->json('ai_matched_volunteers')->nullable()->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('emergency_missions', function (Blueprint $table) {
            $table->dropColumn('ai_matched_volunteers');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['governorate_id']);
            $table->dropColumn(['latitude', 'longitude', 'governorate_id']);
        });

        Schema::dropIfExists('case_image_fingerprints');

        Schema::table('cases', function (Blueprint $table) {
            $table->dropForeign(['duplicate_case_id']);
            $table->dropColumn([
                'ai_urgency_index',
                'ai_triage_tier',
                'ai_vulnerability_factors',
                'ai_invoice_data',
                'ai_fraud_status',
                'duplicate_case_id',
            ]);
        });
    }
};
