<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\FullRegistrationController;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\AdminPanelController;
use App\Http\Middleware\AdminOnly;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register-full', [FullRegistrationController::class, 'registerFull']);
Route::post('/admin/login', [AdminAuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/user', [AuthController::class, 'user']);
Route::middleware('auth:sanctum')->get('/etudiant/statut', function (\Illuminate\Http\Request $request) {
    $email = $request->query('email');
    $student = \App\Models\Student::where('email', $email)->first();
    if (!$student) return response()->json([ 'error'=>'Non trouvé'], 404);
    $registration = $student->registrations()->orderByDesc('created_at')->first();
    return response()->json(['student'=>$student, 'registration'=>$registration]);
});

Route::middleware(['auth:sanctum', AdminOnly::class])->prefix('admin')->group(function () {
    Route::get('/registrations', [AdminPanelController::class, 'listRegistrations']);
    Route::get('/registrations/{id}', [AdminPanelController::class, 'showRegistration']);
    Route::post('/registrations/{id}/status', [AdminPanelController::class, 'updateRegistrationStatus']);
});
