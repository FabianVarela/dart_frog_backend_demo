import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;
import '../mocks/mocks.dart';

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
      (_) => Uri.parse('http://localhost:8080/'),
    );
  });

  group('GET /', () {
    test('responds with a 200 and greeting.', () async {
      // Arrange
      const greeting = 'Welcome to the Dart Frog Demo';

      when(() => mockContext.read<String>()).thenReturn(greeting);
      when(() => mockRequest.method).thenReturn(HttpMethod.get);

      // Act
      final response = route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals(greeting)));
    });
  });

  group('Error 405', () {
    test('Return 405 if method is POST', () {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.post);

      // Act
      final response = route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is PUT', () {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.put);

      // Act
      final response = route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is PATCH', () {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.patch);

      // Act
      final response = route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
    test('Return 405 if method is DELETE', () {
      // Arrange
      when(() => mockRequest.method).thenReturn(HttpMethod.delete);

      // Act
      final response = route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });
}
