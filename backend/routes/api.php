<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CaseController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\GovernorateController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrganizationController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\VolunteerController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
    Route::put('/auth/password', [AuthController::class, 'changePassword']);

    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/governorates', [GovernorateController::class, 'index']);

    Route::get('/cases', [CaseController::class, 'index']);
    Route::get('/cases/{id}', [CaseController::class, 'show']);
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
    Route::post('/organization/request', [OrganizationController::class, 'submitRequest']);

    Route::get('/volunteer/cases', [VolunteerController::class, 'availableCases']);
    Route::get('/volunteer/cases/{id}', [VolunteerController::class, 'showCase']);
    Route::post('/volunteer/apply/{caseId}', [VolunteerController::class, 'apply']);
    Route::get('/volunteer/applications', [VolunteerController::class, 'myApplications']);
    Route::delete('/volunteer/applications/{id}', [VolunteerController::class, 'cancelApplication']);
    Route::get('/volunteer/profile', [VolunteerController::class, 'profile']);
    Route::put('/volunteer/profile', [VolunteerController::class, 'updateProfile']);

    Route::get('/user', [UserController::class, 'show']);
    Route::put('/user', [UserController::class, 'update']);
});
