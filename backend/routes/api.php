<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BeneficiaryController;
use App\Http\Controllers\Api\CaseController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DistributionController;
use App\Http\Controllers\Api\EmergencyMissionController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\FieldAssessmentController;
use App\Http\Controllers\Api\GovernorateController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrganizationController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\VolunteerController;
use App\Http\Controllers\Api\VolunteerPassportController;
use App\Http\Controllers\Api\AiIntelligenceController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/organization/request', [OrganizationController::class, 'submitRequest']);

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/governorates', [GovernorateController::class, 'index']);
Route::get('/cases', [CaseController::class, 'index']);
Route::get('/cases/{id}', [CaseController::class, 'show']);
Route::get('/cases/{id}/comments', [CaseController::class, 'comments']);
Route::post('/cases/{id}/comments', [CaseController::class, 'addComment']);
Route::post('/cases/{id}/like', [CaseController::class, 'toggleLike']);
Route::post('/cases/{id}/donate', [CaseController::class, 'donate']); // open for all donors (guest & auth)

Route::middleware('api.token')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
    Route::put('/auth/password', [AuthController::class, 'changePassword']);

    Route::post('/cases/{id}/views', [CaseController::class, 'incrementViews']);

    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{caseId}', [FavoriteController::class, 'destroy']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/stats', [NotificationController::class, 'stats']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);

    Route::get('/organization/cases', [OrganizationController::class, 'myCases']);
    Route::post('/organization/cases', [OrganizationController::class, 'store']);
    Route::get('/organization/cases/{id}', [OrganizationController::class, 'show']);
    Route::put('/organization/cases/{id}', [OrganizationController::class, 'update']);
    Route::delete('/organization/cases/{id}', [OrganizationController::class, 'destroy']);
    Route::get('/organization/dashboard', [OrganizationController::class, 'dashboard']);
    Route::get('/organization/profile', [OrganizationController::class, 'profile']);
    Route::put('/organization/profile', [OrganizationController::class, 'updateProfile']);
    Route::get('/volunteer/cases', [VolunteerController::class, 'availableCases']);
    Route::get('/volunteer/cases/{id}', [VolunteerController::class, 'showCase']);
    Route::post('/volunteer/apply/{caseId}', [VolunteerController::class, 'apply']);
    Route::get('/volunteer/applications', [VolunteerController::class, 'myApplications']);
    Route::delete('/volunteer/applications/{id}', [VolunteerController::class, 'cancelApplication']);
    Route::get('/volunteer/dashboard', [VolunteerController::class, 'dashboard']);
    Route::get('/volunteer/feed', [VolunteerController::class, 'volunteerCasesFeed']);
    Route::get('/volunteer/my-cases', [VolunteerController::class, 'myAidCases']);
    Route::post('/volunteer/my-cases', [VolunteerController::class, 'storeAidCase']);
    Route::put('/volunteer/my-cases/{id}', [VolunteerController::class, 'updateAidCase']);
    Route::delete('/volunteer/my-cases/{id}', [VolunteerController::class, 'destroyAidCase']);
    Route::get('/volunteer/profile', [VolunteerController::class, 'profile']);
    Route::put('/volunteer/profile', [VolunteerController::class, 'updateProfile']);

    Route::get('/user', [UserController::class, 'show']);
    Route::put('/user', [UserController::class, 'update']);

    // --- Athar Humanitarian Operations & Smart Cards ---
    // Beneficiaries & NFC Cards
    Route::get('/beneficiaries', [BeneficiaryController::class, 'index']);
    Route::post('/beneficiaries', [BeneficiaryController::class, 'store']);
    Route::get('/beneficiaries/{id}', [BeneficiaryController::class, 'show']);
    Route::post('/beneficiaries/lookup', [BeneficiaryController::class, 'lookup']);
    Route::post('/beneficiaries/{id}/pair-nfc', [BeneficiaryController::class, 'pairNfcCard']);

    // NFC & QR Aid Distributions
    Route::get('/distributions/campaigns', [DistributionController::class, 'activeCampaigns']);
    Route::post('/distributions/verify-and-deliver', [DistributionController::class, 'verifyAndDeliver']);
    Route::post('/distributions/batch-sync', [DistributionController::class, 'batchSync']);
    Route::get('/distributions/my', [DistributionController::class, 'myDistributions']);

    // Field Assessments (Home visits)
    Route::get('/field-assessments', [FieldAssessmentController::class, 'index']);
    Route::post('/field-assessments', [FieldAssessmentController::class, 'store']);
    Route::get('/field-assessments/{id}', [FieldAssessmentController::class, 'show']);
    Route::put('/field-assessments/{id}/status', [FieldAssessmentController::class, 'updateStatus']);

    // Emergency Missions (Rapid Response Dispatch)
    Route::get('/emergency-missions', [EmergencyMissionController::class, 'index']);
    Route::post('/emergency-missions', [EmergencyMissionController::class, 'store']);
    Route::get('/emergency-missions/{id}', [EmergencyMissionController::class, 'show']);
    Route::post('/emergency-missions/{id}/join', [EmergencyMissionController::class, 'joinMission']);
    Route::post('/emergency-missions/{id}/check-in', [EmergencyMissionController::class, 'checkIn']);
    Route::get('/emergency-missions/my', [EmergencyMissionController::class, 'myMissions']);

    // Volunteer Digital Passport & Certified Badges
    Route::get('/volunteer/passport/me', [VolunteerPassportController::class, 'myPassport']);

    // Warehouse Inventory
    Route::get('/inventory', [InventoryController::class, 'index']);
    Route::post('/inventory', [InventoryController::class, 'store']);
    Route::post('/inventory/{id}/add-stock', [InventoryController::class, 'addStock']);
    Route::get('/inventory/{id}/transactions', [InventoryController::class, 'transactions']);

    // Phase 4: Applied AI Intelligence Engine
    Route::post('/ai/audit-invoice', [AiIntelligenceController::class, 'auditInvoice']);
    Route::post('/ai/analyze-shelter', [AiIntelligenceController::class, 'analyzeShelter']);
    Route::post('/ai/triage', [AiIntelligenceController::class, 'triageCase']);
    Route::post('/ai/check-fraud', [AiIntelligenceController::class, 'checkImageFraud']);
    Route::get('/ai/match-volunteers/{missionId}', [AiIntelligenceController::class, 'matchVolunteers']);
    Route::post('/ai/cases/{caseId}/audit', [AiIntelligenceController::class, 'fullCaseAiAudit']);
});

// Public Volunteer Certificate Verification (Scanned via QR on printed certificate)
Route::get('/volunteer/passport/verify/{id}', [VolunteerPassportController::class, 'verifyCertificate']);

