import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/json/[id].dart' as route;
import '../../mocks/mocks.dart';

void main() {
  late RequestContext mockContext;
  late Request mockRequest;
  late Uri mockUri;

  const pathId = 'id';

  setUp(() {
    mockContext = MockRequestContext();
    mockRequest = MockRequest();
    mockUri = MockUri();

    // Mock request from context
    when(() => mockContext.request).thenReturn(mockRequest);

    // Mock Uri
    when(() => mockRequest.uri).thenReturn(mockUri);
    when(() => mockUri.resolve(any())).thenAnswer(
      (answer) => Uri.parse(
        'http://localhost:8080/json${answer.positionalArguments.first}',
      ),
    );
    when(() => mockUri.queryParameters).thenReturn({});
  });

  group('GET /json/[id]', () {
    test('Get $UserModel by id and set status code 200', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.get);

      when(() => mockContext.read<String>()).thenReturn(mockServerMessage);
      when(() => mockContext.read<AddressModel>()).thenReturn(mockAddress);

      // Act
      final response = await route.onRequest(mockContext, pathId);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(equals(mockUser.toJson())));
    });
  });

  group('PUT /json/[id]', () {
    test('Update $UserModel by id and set status code 200', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.put);
      when(() => mockContext.read<AddressModel>()).thenReturn(mockAddress);

      when(() => mockRequest.json()).thenAnswer(
        (_) async => <String, dynamic>{'name': 'Dash', 'age': 42},
      );

      // Act
      final response = await route.onRequest(mockContext, pathId);
      final updatedUser = mockUser.copyWith(
        serverMessage: 'Welcome to the new The Dart Side!',
      );

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.json(),
        completion({
          'message': 'Actualizado el id $pathId',
          'body': updatedUser.toJson(),
        }),
      );
    });
  });

  group('DELETE /json/[id]', () {
    test('Delete $UserModel by id and set status code 204', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.delete);

      // Act
      final response = await route.onRequest(mockContext, pathId);

      // Assert
      expect(response.statusCode, equals(HttpStatus.noContent));
      expect(
        response.json(),
        completion({'message': 'Se ha borrado el id $pathId'}),
      );
    });
  });

  group('Error 405', () {
    test('Return 405 if method is POST', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.post);

      // Act
      final response = await route.onRequest(mockContext, pathId);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is PATCH', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.patch);

      // Act
      final response = await route.onRequest(mockContext, pathId);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });
}
