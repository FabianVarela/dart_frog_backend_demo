import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address/address_model.dart';
import 'package:dart_frog_backend_demo/model/user/schema/user_schema.dart';
import 'package:dart_frog_backend_demo/model/user/user_model.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:graphql_server2/graphql_server2.dart';

GraphQL createGraphQL(RequestContext context) {
  final userSchema = createUserSchema(context);

  final schema = graphQLSchema(
    queryType: objectType(
      'Query',
      fields: [
        field(
          'users',
          listOf(userSchema),
          resolve: (_, _) => [
            UserModel(
              name: 'Dash',
              age: 42,
              serverMessage: context.read<String>(),
              address: context.read<AddressModel>(),
            ),
          ],
        ),
        field(
          'findUser',
          userSchema,
          inputs: [GraphQLFieldInput('id', graphQLInt)],
          resolve: (_, args) => UserModel(
            name: 'Dash',
            age: 42,
            serverMessage: context.read<String>(),
            address: context.read<AddressModel>(),
          ),
        ),
      ],
    ),
  );

  return GraphQL(schema);
}
