import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/graphql/graph_ql_schemas.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    final graphQL = createGraphQL(context);
    final subscriptions = <String, StreamSubscription<dynamic>>{};

    channel.stream.listen(
      (message) async {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final type = json['type'] as String?;
          final id = json['id'] as String? ?? 'default';

          switch (type) {
            case 'connection_init':
              channel.sink.add(jsonEncode({'type': 'connection_ack'}));

            case 'subscribe':
            case 'start':
              final payload = json['payload'] as Map<String, dynamic>;
              final query = payload['query'] as String;
              final variables =
                  payload['variables'] as Map<String, dynamic>? ?? {};

              final result = await graphQL.parseAndExecute(
                query,
                variableValues: variables,
              );

              if (result is Stream) {
                // The subscription cancel in the subscription map.
                // ignore: cancel_subscriptions
                final subscription = result.listen(
                  (data) {
                    channel.sink.add(
                      jsonEncode({
                        'id': id,
                        'type': 'next',
                        'payload': {'data': data},
                      }),
                    );
                  },
                  onDone: () {
                    channel.sink.add(
                      jsonEncode({'id': id, 'type': 'complete'}),
                    );
                    subscriptions.remove(id);
                  },
                  onError: (Object error) {
                    channel.sink.add(
                      jsonEncode({
                        'id': id,
                        'type': 'error',
                        'payload': {'message': error.toString()},
                      }),
                    );
                  },
                );
                subscriptions[id] = subscription;
              } else {
                channel.sink.add(
                  jsonEncode({
                    'id': id,
                    'type': 'next',
                    'payload': {'data': result},
                  }),
                );
                channel.sink.add(
                  jsonEncode({'id': id, 'type': 'complete'}),
                );
              }

            case 'stop':
            case 'complete':
              await subscriptions[id]?.cancel();
              subscriptions.remove(id);

            case 'ping':
              channel.sink.add(jsonEncode({'type': 'pong'}));

            default:
              channel.sink.add(
                jsonEncode({
                  'type': 'error',
                  'payload': {'message': 'Unknown message type: $type'},
                }),
              );
          }
        } on FormatException catch (e) {
          channel.sink.add(
            jsonEncode({
              'type': 'error',
              'payload': {'message': 'Invalid JSON: ${e.message}'},
            }),
          );
        } on Exception catch (e) {
          channel.sink.add(
            jsonEncode({
              'type': 'error',
              'payload': {'message': e.toString()},
            }),
          );
        }
      },
      onDone: () async {
        for (final subscription in subscriptions.values) {
          await subscription.cancel();
        }
        subscriptions.clear();
      },
    );
  });

  return handler(context);
}
