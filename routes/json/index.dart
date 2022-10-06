import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';

/*
curl --request GET --url http://localhost:8080/json
curl --request POST --url http://localhost:8080/json \
  --data '{"name": "Argel B.", "age": 30}'
*/

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final serverMessage = context.read<String>();
  final address = context.read<AddressModel>();

  return Response.json(
    body: [
      UserModel(
        name: 'Dash',
        age: 42,
        serverMessage: serverMessage,
        address: address,
      ),
    ],
  );
}

Future<Response> _post(RequestContext context) async {
  final serverMessage = context.read<String>();
  final address = context.read<AddressModel>();

  final request = context.request;

  final userModel = UserModel.fromJson({
    ...await request.json(),
    'serverMessage': serverMessage,
    'address': address.toJson(),
  });

  return Response.json(
    statusCode: HttpStatus.created,
    body: {'message': 'ok', 'body': userModel.toJson()},
  );
}
