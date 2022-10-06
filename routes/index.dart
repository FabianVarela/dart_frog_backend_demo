import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/*
curl --request GET --url http://localhost:8080/
*/

Response onRequest(RequestContext context) {
  final request = context.request;

  switch (request.method) {
    case HttpMethod.get:
      return Response(body: 'Welcome to the Dart Frog Demo');
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
