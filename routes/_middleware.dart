import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/cubit/color/color_manager_cubit.dart';
import 'package:dart_frog_backend_demo/model/address/address_model.dart';
import 'package:dart_frog_backend_demo/websocket/websocket_handler.dart';

final _colorManagerCubit = ColorManagerCubit();

Middleware _colorManagerProvider() {
  return provider<ColorManagerCubit>((_) => _colorManagerCubit);
}

Handler middleware(Handler handler) {
  return handler
      .use((handler) {
        return (context) async {
          // Execute code before request is handled.

          // Forward the request to the respective handler.
          final response = await handler(context);

          // Execute code after request is handled.
          if (response.statusCode >= 400) {
            return response.copyWith(
              body: json.encode({'error_message': 'Ooops'}),
            );
          }

          // Return a response.
          final body = await response.body();
          return response.copyWith(body: body);
        };
      })
      .use(provider<String>((_) => 'Welcome to Not The Dart Side!'))
      .use(
        provider<AddressModel>(
          (_) => const AddressModel(
            street: 'Bogota',
            number: 2503,
            zipCode: 110721,
          ),
        ),
      )
      .use((handler) {
        return (context) async {
          WebSocketHandler.initialize(context);
          return handler(context);
        };
      })
      .use(_colorManagerProvider())
      .use(requestLogger());
}
