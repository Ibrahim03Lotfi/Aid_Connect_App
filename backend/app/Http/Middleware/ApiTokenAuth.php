<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class ApiTokenAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        $plainToken = $request->bearerToken();

        if (! $plainToken) {
            throw new AuthenticationException('Unauthorized');
        }

        $hashedToken = hash('sha256', $plainToken);
        $user = User::where('api_token', $hashedToken)->first();

        if (! $user || ! $user->is_active) {
            throw new AuthenticationException('Unauthorized');
        }

        Auth::setUser($user);
        $request->setUserResolver(fn () => $user);

        return $next($request);
    }
}
