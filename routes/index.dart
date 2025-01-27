import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/*
curl --request GET --url http://localhost:8080/
*/

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.get => Response(body: 'Welcome to the Dart Frog Demo'),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
