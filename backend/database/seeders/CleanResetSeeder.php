<?php

namespace Database\Seeders;

use App\Models\AidCampaign;
use App\Models\AidCase;
use App\Models\AidDistribution;
use App\Models\Beneficiary;
use App\Models\CaseAttachment;
use App\Models\CaseComment;
use App\Models\CaseDonation;
use App\Models\CaseImage;
use App\Models\CaseImageFingerprint;
use App\Models\Category;
use App\Models\EmergencyMission;
use App\Models\Favorite;
use App\Models\FieldAssessment;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\InventoryTransaction;
use App\Models\MissionVolunteer;
use App\Models\NfcCard;
use App\Models\Notification;
use App\Models\OrganizationRequest;
use App\Models\User;
use App\Models\VolunteerApplication;
use App\Models\VolunteerLog;
use App\Models\VolunteerOpportunity;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

class CleanResetSeeder extends Seeder
{
    public function run(): void
    {
        // Disable foreign key constraints during wipe
        Schema::disableForeignKeyConstraints();

        // 1. Wipe all transactional & dynamic data
        CaseComment::truncate();
        CaseAttachment::truncate();
        CaseImage::truncate();
        CaseImageFingerprint::truncate();
        CaseDonation::truncate();
        Favorite::truncate();
        AidCase::truncate();

        AidDistribution::truncate();
        NfcCard::truncate();
        Beneficiary::truncate();

        FieldAssessment::truncate();
        MissionVolunteer::truncate();
        EmergencyMission::truncate();

        AidCampaign::truncate();
        VolunteerApplication::truncate();
        VolunteerLog::truncate();
        VolunteerOpportunity::truncate();
        Notification::truncate();
        OrganizationRequest::truncate();

        InventoryTransaction::truncate();
        InventoryItem::truncate();

        // Wipe non-essential users
        User::truncate();

        Schema::enableForeignKeyConstraints();

        // 2. Ensure Syrian Governorates exist
        $this->call(GovernorateSeeder::class);

        // 3. Ensure Categories exist
        $this->call(CategorySeeder::class);

        $damascus = Governorate::where('name', 'دمشق')->first();

        // 4. Create Clean Standard Test Accounts (password: 'password')
        $hashedPassword = Hash::make('password');

        // A. System Administrator
        User::create([
            'name' => 'مدير النظام (Admin)',
            'email' => 'admin@athar.sy',
            'phone' => '0990000000',
            'password' => $hashedPassword,
            'role' => 'admin',
            'is_active' => true,
            'address' => 'دمشق',
        ]);

        // B. Citizen / Donor (المواطن / المتبرع)
        User::create([
            'name' => 'أحمد العلي (مواطن)',
            'email' => 'citizen@athar.sy',
            'phone' => '0910000001',
            'password' => $hashedPassword,
            'role' => 'user',
            'is_active' => true,
            'address' => 'دمشق',
        ]);

        // C. Field Volunteer (متطوع ميداني معتمد)
        User::create([
            'name' => 'عمر خالد (متطوع ميداني)',
            'email' => 'volunteer@athar.sy',
            'phone' => '0920000001',
            'password' => $hashedPassword,
            'role' => 'volunteer',
            'is_active' => true,
            'address' => 'دمشق - المزة',
            'volunteer_hours' => 24,
            'volunteer_points' => 150,
            'skills' => ['إسعاف أولي', 'مسح ميداني', 'لوجستيات'],
            'has_vehicle' => true,
        ]);

        // D. Partner NGO (جمعية خيرية شريكة)
        User::create([
            'name' => 'جمعية الأمل الخيرية',
            'email' => 'org@athar.sy',
            'phone' => '0930000001',
            'password' => $hashedPassword,
            'role' => 'organization',
            'is_active' => true,
            'registration_number' => 'NGO-DAM-2024-88',
            'address' => 'دمشق - الصالحية',
        ]);

        // 5. Initial Warehouse Stock (Ready for distribution test)
        $foodCategory = Category::where('name', 'like', '%غذاء%')->orWhere('name', 'like', '%طعام%')->first() ?? Category::first();
        $healthCategory = Category::where('name', 'like', '%صح%')->orWhere('name', 'like', '%طب%')->first() ?? Category::first();
        $shelterCategory = Category::where('name', 'like', '%سكن%')->orWhere('name', 'like', '%مأوى%')->first() ?? Category::first();

        InventoryItem::create([
            'name' => 'سلة غذائية عائلية متكاملة',
            'code' => 'FOOD-BSK-01',
            'category_id' => $foodCategory->id,
            'unit' => 'سلة',
            'total_stock' => 200,
            'available_stock' => 200,
            'reserved_stock' => 0,
            'minimum_threshold' => 20,
            'warehouse_location' => 'مستودع الميدان المركزي',
        ]);

        InventoryItem::create([
            'name' => 'حقيبة إسعاف ورعاية صحية طارئة',
            'code' => 'MED-KIT-02',
            'category_id' => $healthCategory->id,
            'unit' => 'حقيبة',
            'total_stock' => 100,
            'available_stock' => 100,
            'reserved_stock' => 0,
            'minimum_threshold' => 15,
            'warehouse_location' => 'صيدلية أثر الميدانية',
        ]);

        InventoryItem::create([
            'name' => 'بطانية شتوية حرارية مزدوجة',
            'code' => 'SHELTER-BLNK-03',
            'category_id' => $shelterCategory->id,
            'unit' => 'بطانية',
            'total_stock' => 250,
            'available_stock' => 250,
            'reserved_stock' => 0,
            'minimum_threshold' => 30,
            'warehouse_location' => 'مستودع صحنايا الإقليمي',
        ]);
    }
}
