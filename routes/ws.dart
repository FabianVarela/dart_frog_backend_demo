import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/websocket/websocket_handler.dart';

Future<Response> onRequest(RequestContext context) async {
  return WebSocketHandler.handleConnection(context);
}
