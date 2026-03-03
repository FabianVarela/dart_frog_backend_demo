import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address/address_model.dart';
import 'package:dart_frog_backend_demo/model/user/user_model.dart';
import 'package:graphql_schema2/graphql_schema2.dart';

GraphQLObjectType createUserSchema(RequestContext context) {
  final userType = objectType(
    'User',
    fields: [
      field(
        'name',
        graphQLString,
        resolve: (obj, _) => (obj as UserModel).name,
      ),
      field('age', graphQLInt, resolve: (obj, _) => (obj as UserModel).age),
      field(
        'serverMessage',
        graphQLString,
        resolve: (obj, _) => (obj as UserModel).serverMessage,
      ),
      field(
        'address',
        objectType(
          'Address',
          fields: [
            field(
              'street',
              graphQLString,
              resolve: (obj, _) => (obj as AddressModel).street,
            ),
            field(
              'number',
              graphQLInt,
              resolve: (obj, _) => (obj as AddressModel).number,
            ),
            field(
              'zipCode',
              graphQLInt,
              resolve: (obj, _) => (obj as AddressModel).zipCode,
            ),
          ],
        ),
        resolve: (obj, _) => (obj as UserModel).address,
      ),
    ],
  );
  return userType;
}
