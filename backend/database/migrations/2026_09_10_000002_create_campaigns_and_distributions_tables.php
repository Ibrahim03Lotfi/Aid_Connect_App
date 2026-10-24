<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('aid_campaigns', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->enum('status', ['planning', 'active', 'completed', 'paused'])->default('active');
            $table->string('item_type')->default('سلة غذائية');
            $table->unsignedSmallInteger('items_allocated_per_family')->default(1);
            $table->unsignedInteger('target_families_count')->default(100);
            $table->unsignedInteger('distributed_families_count')->default(0);
            $table->timestamps();
        });

        Schema::create('aid_distributions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained('aid_campaigns')->onDelete('cascade');
            $table->foreignId('beneficiary_id')->constrained('beneficiaries')->onDelete('cascade');
            $table->foreignId('volunteer_id')->constrained('users')->onDelete('cascade');
            $table->enum('verification_method', ['nfc_tap', 'qr_scan', 'manual_override'])->default('nfc_tap');
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('photo_proof')->nullable();
            $table->timestamp('distributed_at')->useCurrent();
            $table->boolean('is_offline_synced')->default(false);
            $table->text('notes')->nullable();
            $table->timestamps();

            // Enforce: one distribution per beneficiary per campaign!
            $table->unique(['campaign_id', 'beneficiary_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('aid_distributions');
        Schema::dropIfExists('aid_campaigns');
    }
};
