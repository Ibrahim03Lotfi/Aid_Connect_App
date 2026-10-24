<?php

use App\Http\Controllers\Web\AdminDashboardController;
use Illuminate\Support\Facades\Route;

// Redirect root to operations dashboard
Route::get('/', function () {
    return redirect()->route('dashboard.index');
});

Route::prefix('dashboard')->name('dashboard.')->group(function () {
    // 5.1 Main Operations Dashboard
    Route::get('/', [AdminDashboardController::class, 'index'])->name('index');

    // 5.2 Live Field Operations Map (GIS)
    Route::get('/gis-map', [AdminDashboardController::class, 'gisMap'])->name('gis');
    Route::get('/api/gis-data', [AdminDashboardController::class, 'gisData'])->name('gis.data');

    // 5.3 AI Triage & Case Review Board
    Route::get('/cases', [AdminDashboardController::class, 'cases'])->name('cases');
    Route::post('/cases', [AdminDashboardController::class, 'storeCase'])->name('cases.store');
    Route::put('/cases/{id}', [AdminDashboardController::class, 'updateCase'])->name('cases.update');
    Route::delete('/cases/{id}', [AdminDashboardController::class, 'destroyCase'])->name('cases.destroy');
    Route::post('/cases/{id}/assign', [AdminDashboardController::class, 'assignVolunteer'])->name('cases.assign');
    Route::post('/cases/{id}/approve', [AdminDashboardController::class, 'approveCase'])->name('cases.approve');
    Route::post('/cases/{id}/reject', [AdminDashboardController::class, 'rejectCase'])->name('cases.reject');

    // 5.4 Beneficiary & NFC Card Management Hub
    Route::get('/beneficiaries', [AdminDashboardController::class, 'beneficiaries'])->name('beneficiaries');
    Route::post('/beneficiaries', [AdminDashboardController::class, 'storeBeneficiary'])->name('beneficiaries.store');
    Route::put('/beneficiaries/{id}', [AdminDashboardController::class, 'updateBeneficiary'])->name('beneficiaries.update');
    Route::delete('/beneficiaries/{id}', [AdminDashboardController::class, 'destroyBeneficiary'])->name('beneficiaries.destroy');

    // 5.5 Logistics & Aid Inventory System
    Route::get('/inventory', [AdminDashboardController::class, 'inventory'])->name('inventory');
    Route::post('/inventory/items', [AdminDashboardController::class, 'storeInventoryItem'])->name('inventory.items.store');
    Route::put('/inventory/items/{id}', [AdminDashboardController::class, 'updateInventoryItem'])->name('inventory.items.update');
    Route::delete('/inventory/items/{id}', [AdminDashboardController::class, 'destroyInventoryItem'])->name('inventory.items.destroy');
    Route::post('/inventory/add-stock', [AdminDashboardController::class, 'addStock'])->name('inventory.add-stock');
    Route::post('/warehouses', [AdminDashboardController::class, 'storeWarehouse'])->name('warehouses.store');
    Route::put('/warehouses/{id}', [AdminDashboardController::class, 'updateWarehouse'])->name('warehouses.update');
    Route::delete('/warehouses/{id}', [AdminDashboardController::class, 'destroyWarehouse'])->name('warehouses.destroy');

    // 5.6 Executive Analytics & Impact Report
    Route::get('/analytics', [AdminDashboardController::class, 'analytics'])->name('analytics');
    Route::get('/reports/annual-impact', [AdminDashboardController::class, 'impactReport'])->name('reports.annual');

    // --- End-to-End Enterprise Control Modules ---
    // 1. Aid Campaigns Manager
    Route::get('/campaigns', [AdminDashboardController::class, 'campaigns'])->name('campaigns');
    Route::post('/campaigns', [AdminDashboardController::class, 'storeCampaign'])->name('campaigns.store');
    Route::put('/campaigns/{id}', [AdminDashboardController::class, 'updateCampaign'])->name('campaigns.update');
    Route::delete('/campaigns/{id}', [AdminDashboardController::class, 'destroyCampaign'])->name('campaigns.destroy');
    Route::post('/campaigns/{id}/toggle-status', [AdminDashboardController::class, 'toggleCampaignStatus'])->name('campaigns.toggle');

    // 2. Emergency Missions & Volunteer Dispatch
    Route::get('/missions', [AdminDashboardController::class, 'missions'])->name('missions');
    Route::post('/missions', [AdminDashboardController::class, 'storeMission'])->name('missions.store');
    Route::put('/missions/{id}', [AdminDashboardController::class, 'updateMission'])->name('missions.update');
    Route::delete('/missions/{id}', [AdminDashboardController::class, 'destroyMission'])->name('missions.destroy');
    Route::post('/missions/{id}/close', [AdminDashboardController::class, 'closeMission'])->name('missions.close');
    Route::post('/missions/{id}/reopen', [AdminDashboardController::class, 'reopenMission'])->name('missions.reopen');

    // 3. Volunteer Roster & Hours Certification
    Route::get('/volunteers', [AdminDashboardController::class, 'volunteers'])->name('volunteers');
    Route::post('/volunteers/{id}/log-hours', [AdminDashboardController::class, 'logVolunteerHours'])->name('volunteers.log-hours');
    Route::post('/volunteers/{id}/award-badge', [AdminDashboardController::class, 'awardVolunteerBadge'])->name('volunteers.award-badge');

    // 4. Field Living Condition Surveys & Inspection Review
    Route::get('/assessments', [AdminDashboardController::class, 'fieldAssessments'])->name('assessments');
    Route::post('/assessments/{id}/status', [AdminDashboardController::class, 'updateAssessmentStatus'])->name('assessments.status');

    // 5. Donations & Financial Transparency Ledger
    Route::get('/donations', [AdminDashboardController::class, 'donations'])->name('donations');
    Route::post('/donations', [AdminDashboardController::class, 'storeDonation'])->name('donations.store');
    Route::post('/donations/{id}/approve', [AdminDashboardController::class, 'approveDonation'])->name('donations.approve');
    Route::post('/donations/{id}/reject', [AdminDashboardController::class, 'rejectDonation'])->name('donations.reject');

    // 6. Volunteer Opportunities & Recruitment Applications
    Route::post('/volunteers/opportunities', [AdminDashboardController::class, 'storeOpportunity'])->name('volunteers.opportunities.store');
    Route::put('/volunteers/opportunities/{id}', [AdminDashboardController::class, 'updateOpportunity'])->name('volunteers.opportunities.update');
    Route::delete('/volunteers/opportunities/{id}', [AdminDashboardController::class, 'destroyOpportunity'])->name('volunteers.opportunities.destroy');
    Route::post('/volunteers/opportunities/{id}/toggle-status', [AdminDashboardController::class, 'toggleOpportunityStatus'])->name('volunteers.opportunities.toggle');
    Route::post('/volunteers/applications/{id}/status', [AdminDashboardController::class, 'updateApplicationStatus'])->name('volunteers.applications.status');

    // 7. NGO Partners & Accreditation Hub
    Route::get('/organizations', [AdminDashboardController::class, 'organizations'])->name('organizations');
    Route::post('/organizations/{id}/approve', [AdminDashboardController::class, 'approveOrganization'])->name('organizations.approve');
    Route::post('/organizations/{id}/reject', [AdminDashboardController::class, 'rejectOrganization'])->name('organizations.reject');

    // 8. Emergency Broadcast & Notifications
    Route::get('/notifications', [AdminDashboardController::class, 'notifications'])->name('notifications');
    Route::post('/notifications/broadcast', [AdminDashboardController::class, 'broadcastNotification'])->name('notifications.broadcast');

    // 9. NFC Distributions Audit Ledger & 3D Hardware Simulator
    Route::get('/distributions', [AdminDashboardController::class, 'distributions'])->name('distributions');
    Route::get('/distributions/nfc-simulator-data', [AdminDashboardController::class, 'nfcSimulatorData'])->name('distributions.nfc-data');
    Route::post('/distributions/simulate-nfc-tap', [AdminDashboardController::class, 'simulateNfcTap'])->name('distributions.simulate-nfc-tap');

    // 10. AI Intelligence & Fraud Diagnostics Lab
    Route::get('/ai-intelligence', [AdminDashboardController::class, 'aiIntelligence'])->name('ai');
    Route::post('/ai-intelligence/simulate', [AdminDashboardController::class, 'simulateAiTriage'])->name('ai.simulate');

    // 11. System Users & Roles Governance
    Route::get('/users', [AdminDashboardController::class, 'users'])->name('users');
    Route::post('/users', [AdminDashboardController::class, 'storeUser'])->name('users.store');
    Route::put('/users/{id}', [AdminDashboardController::class, 'updateUser'])->name('users.update');
    Route::delete('/users/{id}', [AdminDashboardController::class, 'destroyUser'])->name('users.destroy');
    Route::post('/users/{id}/toggle-status', [AdminDashboardController::class, 'toggleUserStatus'])->name('users.toggle');
    Route::post('/users/{id}/update-role', [AdminDashboardController::class, 'updateUserRole'])->name('users.role');

    // 12. Platform Settings & System Health
    Route::get('/settings', [AdminDashboardController::class, 'settings'])->name('settings');
    Route::post('/settings/categories', [AdminDashboardController::class, 'storeCategory'])->name('settings.categories.store');
    Route::put('/settings/categories/{id}', [AdminDashboardController::class, 'updateCategory'])->name('settings.categories.update');
    Route::delete('/settings/categories/{id}', [AdminDashboardController::class, 'destroyCategory'])->name('settings.categories.destroy');
    Route::post('/settings/governorates', [AdminDashboardController::class, 'storeGovernorate'])->name('settings.governorates.store');
    Route::put('/settings/governorates/{id}', [AdminDashboardController::class, 'updateGovernorate'])->name('settings.governorates.update');
    Route::delete('/settings/governorates/{id}', [AdminDashboardController::class, 'destroyGovernorate'])->name('settings.governorates.destroy');
});
