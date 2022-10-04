import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/json/index.dart' as route;
import '../../mocks/mocks.dart';

void main() {
  late RequestContext mockContext;
  late Request mockRequest;
  late Uri mockUri;

  setUp(() {
    mockContext = MockRequestContext();
    mockRequest = MockRequest();
    mockUri = MockUri();

    // Mock request from context
    when(() => mockContext.request).thenReturn(mockRequest);

    // Mock Uri
    when(() => mockRequest.uri).thenReturn(mockUri);
    when(() => mockUri.resolve(any())).thenAnswer(
      (_) => Uri.parse(
        'http://localhost:8080/json${_.positionalArguments.first}',
      ),
    );
  });

  group('GET /', () {
    test('Get $UserModel with status code 200', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.get);

      when(() => mockContext.read<String>()).thenReturn(mockServerMessage);
      when(() => mockContext.read<AddressModel>()).thenReturn(mockAddress);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.json(), completion(equals([mockUser.toJson()])));
    });
  });

  group('POST /', () {
    test('Send $UserModel with status code 201', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.post);

      when(() => mockContext.read<String>()).thenReturn(mockServerMessage);
      when(() => mockContext.read<AddressModel>()).thenReturn(mockAddress);

      when(() => mockRequest.json()).thenAnswer(
        (_) async => <String, dynamic>{'name': 'Dash', 'age': 42},
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.created));
      expect(
        response.json(),
        completion({'message': 'ok', 'body': mockUser.toJson()}),
      );
    });
  });

  group('Error 405', () {
    test('Return 405 if method is PUT', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.put);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is PATCH', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.patch);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is DELETE', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.delete);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });
}
