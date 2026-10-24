<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('beneficiaries', function (Blueprint $table) {
            $table->id();
            $table->string('full_name');
            $table->string('national_id', 20)->unique();
            $table->string('phone', 25)->nullable();
            $table->unsignedSmallInteger('family_members_count')->default(1);
            $table->foreignId('governorate_id')->constrained('governorates')->onDelete('cascade');
            $table->string('district')->nullable();
            $table->text('address_details')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->unsignedTinyInteger('vulnerability_score')->default(50); // 1-100
            $table->string('nfc_card_uid', 64)->unique()->nullable();
            $table->string('qr_token', 64)->unique();
            $table->enum('status', ['active', 'suspended', 'pending_verification'])->default('active');
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('nfc_cards', function (Blueprint $table) {
            $table->id();
            $table->string('card_uid', 64)->unique();
            $table->foreignId('beneficiary_id')->constrained('beneficiaries')->onDelete('cascade');
            $table->boolean('is_active')->default(true);
            $table->timestamp('issued_at')->useCurrent();
            $table->timestamp('last_scanned_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nfc_cards');
        Schema::dropIfExists('beneficiaries');
    }
};
