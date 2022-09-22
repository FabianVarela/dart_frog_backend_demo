import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';

import '../_middleware.dart';

Response onRequest(RequestContext context) {
  final serverMessage = context.read<String>();
  final address = context.read<AddressModel>();

  final greeting = context.read<MyString>();
  print(greeting);

  return Response.json(
    body: UserModel(
      name: 'Dash',
      age: 42,
      serverMessage: serverMessage,
      address: address,
    ),
  );
}
