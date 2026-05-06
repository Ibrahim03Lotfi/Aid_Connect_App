<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;

class UserController extends ApiController
{
    public function show(Request $request)
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

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'avatar' => 'sometimes|string|max:2048',
        ]);

        $user->update($validated);

        return $this->successResponse(null, 'User updated successfully');
    }
}
