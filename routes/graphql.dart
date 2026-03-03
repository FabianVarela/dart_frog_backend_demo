import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/graphql/graph_ql_schemas.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != .post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final queryJson = await context.request.json();
  if (queryJson is! Map<String, dynamic> || !queryJson.containsKey('query')) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Missing "query" field in JSON.',
    );
  }

  final query = queryJson['query'] as String;
  final variables = queryJson['variables'] as Map<String, dynamic>?;

  final graphQL = createGraphQL(context);
  final data = await graphQL.parseAndExecute(
    query,
    variableValues: variables ?? {},
  );

  return Response.json(body: {'data': data as Map<String, dynamic>});
}
