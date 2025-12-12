import 'dart:async';
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/cubit/color/color_manager_cubit.dart';
import 'package:dart_frog_backend_demo/model/color/color_model.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:uuid/uuid.dart';

class WebSocketHandler {
  static late StreamSubscription<ColorMixModel> _subscription;
  static final Map<String, WebSocketChannel> _connections = {};

  static void initialize(RequestContext context) {
    final colorManagerCubit = context.read<ColorManagerCubit>();
    _subscription = colorManagerCubit.stream.listen((state) {
      final message = jsonEncode({
        'type': 'state_update',
        'payload': state.toJson(),
      });
      _broadcastToAll(context, message);
    });
  }

  static Future<Response> handleConnection(RequestContext context) async {
    final colorManagerCubit = context.read<ColorManagerCubit>();
    return webSocketHandler((channel, protocol) {
      final userId = const Uuid().v4();

      _connections[userId] = channel;
      colorManagerCubit.userConnected(userId);

      final initialMessage = jsonEncode({
        'type': 'initial_state',
        'payload': {
          'userId': userId,
          'currentState': colorManagerCubit.state.toJson(),
        },
      });
      channel.sink.add(initialMessage);

      channel.stream.listen(
        (message) => _handleMessage(context, userId, message),
        onDone: () => _handleDisconnection(context, userId),
        onError: (dynamic error) => _handleError(context, userId, error),
      );
    })(context);
  }

  static void _handleMessage(
    RequestContext context,
    String userId,
    dynamic message,
  ) {
    try {
      final colorManagerCubit = context.read<ColorManagerCubit>();
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'update_color':
          final colorData = data['data'] as Map<String, dynamic>;
          final newColorRgb = (
            red: colorData['red'] as int? ?? 128,
            green: colorData['green'] as int? ?? 128,
            blue: colorData['blue'] as int? ?? 128,
          );

          colorManagerCubit.updateColor(newColorRgb, userId);
        case 'reset_color':
          colorManagerCubit.resetColor();
        case 'ping':
          _sendToUser(context, userId, jsonEncode({'type': 'pong'}));
        default:
          print('Unknown message type: $type');
      }
    } on Exception catch (e) {
      print('Error handling message from $userId: $e');
      _sendToUser(
        context,
        userId,
        jsonEncode({
          'type': 'error',
          'payload': 'Invalid message format',
        }),
      );
    }
  }

  static void _handleDisconnection(RequestContext context, String userId) {
    final colorManagerCubit = context.read<ColorManagerCubit>();

    _connections.remove(userId);
    colorManagerCubit.userDisconnected(userId);

    print('User $userId disconnected');
  }

  static void _handleError(
    RequestContext context,
    String userId,
    dynamic error,
  ) {
    print('WebSocket error for user $userId: $error');
    _handleDisconnection(context, userId);
  }

  static void _sendToUser(
    RequestContext context,
    String userId,
    String message,
  ) {
    final connection = _connections[userId];
    if (connection != null) {
      try {
        connection.sink.add(message);
      } on Exception catch (e) {
        print('Error sending message to $userId: $e');
        _handleDisconnection(context, userId);
      }
    }
  }

  static void _broadcastToAll(RequestContext context, String message) {
    final disconnectedUsers = <String>[];

    for (final channel in _connections.entries) {
      try {
        channel.value.sink.add(message);
      } on Exception catch (e) {
        print('Error broadcasting to ${channel.key}: $e');
        disconnectedUsers.add(channel.key);
      }
    }

    for (final userId in disconnectedUsers) {
      _handleDisconnection(context, userId);
    }
  }

  static Future<void> dispose() async {
    await _subscription.cancel();
    for (final channel in _connections.values) {
      await channel.sink.close();
    }
    _connections.clear();
  }
}
