import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/graphql/graphql_subscriptions.dart';
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
          resolve: (_, args) {
            final user = UserModel(
              name: args['name'] as String,
              age: args['age'] as int,
              serverMessage: 'User created successfully!',
              address: context.read<AddressModel>(),
            );
            GraphQLSubscriptions.instance.notifyUserCreated(user);
            return user;
          },
        ),
        field(
          'updateUser',
          userSchema,
          inputs: [
            GraphQLFieldInput('id', graphQLInt.nonNullable()),
            GraphQLFieldInput('name', graphQLString),
            GraphQLFieldInput('age', graphQLInt),
          ],
          resolve: (_, args) {
            final user = UserModel(
              name: args['name'] as String? ?? 'Dash',
              age: args['age'] as int? ?? 42,
              serverMessage: 'User ${args['id'] as int} updated successfully!',
              address: context.read<AddressModel>(),
            );
            GraphQLSubscriptions.instance.notifyUserUpdated(user);
            return user;
          },
        ),
        field(
          'deleteUser',
          graphQLBoolean,
          inputs: [GraphQLFieldInput('id', graphQLInt.nonNullable())],
          resolve: (_, args) {
            final id = args['id'] as int;
            GraphQLSubscriptions.instance.notifyUserDeleted(id);
            return true;
          },
        ),
      ],
    ),
    subscriptionType: objectType(
      'Subscription',
      fields: [
        field(
          'onUserCreated',
          userSchema,
          resolve: (_, _) => GraphQLSubscriptions.instance.onUserCreated.map(
            (user) => {'onUserCreated': user},
          ),
        ),
        field(
          'onUserUpdated',
          userSchema,
          resolve: (_, _) => GraphQLSubscriptions.instance.onUserUpdated.map(
            (user) => {'onUserUpdated': user},
          ),
        ),
        field(
          'onUserDeleted',
          graphQLInt,
          resolve: (_, _) => GraphQLSubscriptions.instance.onUserDeleted.map(
            (id) => {'onUserDeleted': id},
          ),
        ),
        field(
          'countdown',
          graphQLInt,
          inputs: [GraphQLFieldInput('from', graphQLInt.nonNullable())],
          resolve: (_, args) => GraphQLSubscriptions.instance
              .countdown(args['from'] as int)
              .map((value) => {'countdown': value}),
        ),
      ],
    ),
  );

  return GraphQL(schema);
}
