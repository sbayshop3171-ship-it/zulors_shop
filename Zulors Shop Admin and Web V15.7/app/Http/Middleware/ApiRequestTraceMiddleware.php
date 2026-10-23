<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class ApiRequestTraceMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $candidate = (string) $request->header('X-Request-Id', '');
        $requestId = preg_match('/^[A-Za-z0-9._-]{1,80}$/', $candidate) === 1
            ? $candidate
            : (string) Str::uuid();
        $startedAt = hrtime(true);

        $request->attributes->set('request_id', $requestId);
        try {
            $response = $next($request);
        } catch (Throwable $exception) {
            Log::error('API request raised an exception', [
                'request_id' => $requestId,
                'method' => $request->method(),
                'path' => $request->path(),
                'exception' => $exception::class,
                'duration_ms' => round((hrtime(true) - $startedAt) / 1_000_000, 2),
            ]);
            throw $exception;
        }

        $durationMs = round((hrtime(true) - $startedAt) / 1_000_000, 2);
        $response->headers->set('X-Request-Id', $requestId);

        if ($response->getStatusCode() >= 400 || $durationMs >= 1500) {
            Log::warning('API request completed with an error or slow response', [
                'request_id' => $requestId,
                'method' => $request->method(),
                'path' => $request->path(),
                'status' => $response->getStatusCode(),
                'duration_ms' => $durationMs,
            ]);
        }

        return $response;
    }
}
