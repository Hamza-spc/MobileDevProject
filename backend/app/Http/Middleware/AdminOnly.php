<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnly
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (!$user || $user->email !== 'admin@etudes.com') {
            return response(['message' => 'Unauthorized'], 401);
        }
        return $next($request);
    }
}
