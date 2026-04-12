import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    .get => _handleLiveHealthCheck(),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _handleLiveHealthCheck() {
  return Response(
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'status': 'alive'}),
  );
}
