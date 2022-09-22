import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';

String? _greeting;

typedef MyString = String;

Middleware cachedGreetingProvider() {
  return provider<MyString>((context) => _greeting ??= 'Hello World');
}

Handler middleware(Handler handler) {
  return handler
      .use((handler) {
        return (context) async {
          // Execute code before request is handled.

          // Forward the request to the respective handler.
          final response = await handler(context);

          // Execute code after request is handled.
          if (response.statusCode != 200) {
            return response.copyWith(body: json.encode({'value': 'Ooops'}));
          }

          // Return a response.
          final body = await response.body();
          return response.copyWith(body: body);
        };
      })
      .use(requestLogger())
      .use(cachedGreetingProvider())
      .use(provider<String>((context) => 'Welcome to Not The Dart Side!'))
      .use(
        provider<AddressModel>(
          (context) => const AddressModel(
            street: 'Bogota',
            number: 2503,
            zipCode: 110721,
          ),
        ),
      );
}
