import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';

/*
curl --request GET --url http://localhost:8080/json/<id>
curl --request PUT --url http://localhost:8080/json/<id> \
  --data '{"name": "Fabian V.", "age": 30}'
curl --request DELETE --url http://localhost:8080/json/<id>
*/

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.put:
      return _put(context, id);
    case HttpMethod.delete:
      return _delete(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final serverMessage = context.read<String>();
  final address = context.read<AddressModel>();

  return Response.json(
    body: UserModel(
      name: 'Dash',
      age: 42,
      serverMessage: serverMessage,
      address: address,
    ),
  );
}

Future<Response> _put(RequestContext context, String id) async {
  final address = context.read<AddressModel>();

  final request = await context.request.json();
  final userModel = UserModel.fromJson({
    ...request,
    'serverMessage': 'Welcome to the new The Dart Side!',
    'address': address.toJson(),
  });

  return Response.json(
    body: {'message': 'Actualizado el id $id', 'body': userModel.toJson()},
  );
}

Future<Response> _delete(RequestContext context, String id) async {
  return Response.json(
    statusCode: HttpStatus.noContent,
    body: {'message': 'Se ha borrado el id $id'},
  );
}
