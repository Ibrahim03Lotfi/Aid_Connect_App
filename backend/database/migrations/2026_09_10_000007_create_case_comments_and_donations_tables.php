<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('case_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->constrained('cases')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->text('comment');
            $table->timestamps();
        });

        Schema::create('case_donations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->constrained('cases')->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->decimal('amount', 14, 2);
            $table->string('currency', 10)->default('SYP');
            $table->enum('payment_method', ['sham_cash', 'syriatel_cash', 'in_kind', 'manual'])->default('sham_cash');
            $table->string('donor_name')->default('فاعل خير');
            $table->string('donor_phone')->nullable();
            $table->string('transaction_ref')->unique();
            $table->enum('status', ['completed', 'pending', 'failed'])->default('completed');
            $table->timestamps();
        });

        // Add target_amount and collected_amount to cases if not present
        Schema::table('cases', function (Blueprint $table) {
            $table->decimal('target_amount', 14, 2)->default(1000000)->after('priority');
            $table->decimal('collected_amount', 14, 2)->default(450000)->after('target_amount');
            $table->unsignedInteger('likes_count')->default(42)->after('collected_amount');
        });
    }

    public function down(): void
    {
        Schema::table('cases', function (Blueprint $table) {
            $table->dropColumn(['target_amount', 'collected_amount', 'likes_count']);
        });
        Schema::dropIfExists('case_donations');
        Schema::dropIfExists('case_comments');
    }
};
