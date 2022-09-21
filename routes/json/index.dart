import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: const UserModel(name: 'Dash', age: 42),
  );
}
