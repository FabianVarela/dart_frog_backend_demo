import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

final _startTime = DateTime.now();

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    .get => _handleHealthCheck(),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _handleHealthCheck() {
  final now = DateTime.now();
  final uptime = now.difference(_startTime).inSeconds;

  return Response(
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'status': 'ok',
      'timestamp': now.toIso8601String(),
      'uptime_seconds': uptime,
      'service': 'dart_frog_backend_demo',
    }),
  );
}
