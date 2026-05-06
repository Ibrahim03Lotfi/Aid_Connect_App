<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends ApiController
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'role' => 'required|in:user,organization,volunteer,admin',
        ]);

        $user = User::where('email', $request->email)
            ->where('role', $request->role)
            ->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return $this->errorResponse('Invalid credentials', 401);
        }

        if (! $user->is_active) {
            return $this->errorResponse('Account is deactivated', 403);
        }

        $plainToken = Str::random(80);
        $user->update([
            'api_token' => hash('sha256', $plainToken),
        ]);

        return $this->successResponse([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'avatar' => $user->avatar,
            'is_active' => $user->is_active,
            'token' => $plainToken,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
        ], 'Login successful');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => 'user',
            'is_active' => true,
        ]);

        $plainToken = Str::random(80);
        $user->update([
            'api_token' => hash('sha256', $plainToken),
        ]);

        return $this->successResponse([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'avatar' => $user->avatar,
            'is_active' => $user->is_active,
            'token' => $plainToken,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
        ], 'Registration successful');
    }

    public function logout(Request $request)
    {
        $request->user()->update(['api_token' => null]);
        return $this->successResponse(null, 'Logout successful');
    }

    public function me(Request $request)
    {
        $user = $request->user();
        return $this->successResponse([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'avatar' => $user->avatar,
            'is_active' => $user->is_active,
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'avatar' => 'sometimes|string|max:2048',
        ]);

        $user->update($validated);

        return $this->successResponse(null, 'Profile updated successfully');
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|string|min:6',
        ]);

        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            return $this->errorResponse('Current password is incorrect', 422);
        }

        $user->update(['password' => Hash::make($request->new_password)]);

        return $this->successResponse(null, 'Password changed successfully');
    }
}
