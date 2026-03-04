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
    mutationType: objectType(
      'Mutation',
      fields: [
        field(
          'createUser',
          userSchema,
          inputs: [
            GraphQLFieldInput('name', graphQLString.nonNullable()),
            GraphQLFieldInput('age', graphQLInt.nonNullable()),
          ],
          resolve: (_, args) => UserModel(
            name: args['name'] as String,
            age: args['age'] as int,
            serverMessage: 'User created successfully!',
            address: context.read<AddressModel>(),
          ),
        ),
        field(
          'updateUser',
          userSchema,
          inputs: [
            GraphQLFieldInput('id', graphQLInt.nonNullable()),
            GraphQLFieldInput('name', graphQLString),
            GraphQLFieldInput('age', graphQLInt),
          ],
          resolve: (_, args) => UserModel(
            name: args['name'] as String? ?? 'Dash',
            age: args['age'] as int? ?? 42,
            serverMessage: 'User ${args['id'] as int} updated successfully!',
            address: context.read<AddressModel>(),
          ),
        ),
        field(
          'deleteUser',
          graphQLBoolean,
          inputs: [GraphQLFieldInput('id', graphQLInt.nonNullable())],
          resolve: (_, args) {
            // Here you would delete the user from your data using the ID.
            // ignore: unused_local_variable
            final id = args['id'] as int;
            return true;
          },
        ),
      ],
    ),
  );

  return GraphQL(schema);
}
