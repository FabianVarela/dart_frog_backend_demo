import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

class RateLimiter {
  RateLimiter({required this.maxRequests, required this.windowDuration});

  final int maxRequests;
  final Duration windowDuration;

  final Map<String, List<DateTime>> _requests = {};

  bool isRateLimited(String ipAddress) {
    final now = DateTime.now();
    final requests = _requests.putIfAbsent(ipAddress, () => [])
      ..removeWhere((timestamp) => now.difference(timestamp) > windowDuration);

    if (requests.length >= maxRequests) return true;

    requests.add(now);
    return false;
  }

  int getRemainingRequests(String ipAddress) {
    final requests = _requests[ipAddress] ?? [];
    final remaining = maxRequests - requests.length;
    return remaining > 0 ? remaining : 0;
  }

  DateTime? getResetTime(String ipAddress) {
    final requests = _requests[ipAddress];
    if (requests == null || requests.isEmpty) return null;
    return requests.first.add(windowDuration);
  }

  void cleanup() {
    final now = DateTime.now();
    _requests.removeWhere((ip, requests) {
      requests.removeWhere(
        (timestamp) => now.difference(timestamp) > windowDuration,
      );
      return requests.isEmpty;
    });
  }
}

Middleware rateLimitMiddleware({
  int maxRequests = 100,
  Duration windowDuration = const Duration(minutes: 1),
}) {
  final rateLimiter = RateLimiter(
    maxRequests: maxRequests,
    windowDuration: windowDuration,
  );

  return (handler) {
    return (context) async {
      final request = context.request;
      final ipAddress = _getClientIp(request);

      if (rateLimiter.isRateLimited(ipAddress)) {
        final resetTime = rateLimiter.getResetTime(ipAddress);

        final retryAfter = resetTime != null
            ? resetTime.difference(DateTime.now()).inSeconds
            : windowDuration.inSeconds;

        return Response(
          statusCode: HttpStatus.tooManyRequests,
          headers: {
            'X-RateLimit-Limit': maxRequests.toString(),
            'X-RateLimit-Remaining': '0',
            'X-RateLimit-Reset': resetTime?.toIso8601String() ?? '',
            'Retry-After': retryAfter.toString(),
          },
          body: 'Too many requests. Please try again later.',
        );
      }

      final response = await handler(context);
      final remaining = rateLimiter.getRemainingRequests(ipAddress);
      final resetTime = rateLimiter.getResetTime(ipAddress);

      return response.copyWith(
        headers: {
          ...response.headers,
          'X-RateLimit-Limit': maxRequests.toString(),
          'X-RateLimit-Remaining': remaining.toString(),
          if (resetTime != null)
            'X-RateLimit-Reset': resetTime.toIso8601String(),
        },
      );
    };
  };
}

String _getClientIp(Request request) {
  final forwardedFor = request.headers['x-forwarded-for'];
  if (forwardedFor != null && forwardedFor.isNotEmpty) {
    return forwardedFor.split(',').first.trim();
  }

  final realIp = request.headers['x-real-ip'];
  if (realIp != null && realIp.isNotEmpty) return realIp;

  return request.headers['host'] ?? 'unknown';
}
