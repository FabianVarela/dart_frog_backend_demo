import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address/address_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/graphql.dart' as route;
import '../mocks/mocks.dart';

void main() {
  late RequestContext mockContext;
  late Request mockRequest;
  late Uri mockUri;

  setUp(() {
    mockContext = MockRequestContext();
    mockRequest = MockRequest();
    mockUri = MockUri();

    when(() => mockContext.request).thenReturn(mockRequest);
    when(() => mockRequest.uri).thenReturn(mockUri);
    when(() => mockUri.resolve(any())).thenAnswer(
      (_) => Uri.parse('http://localhost:8080/graphql'),
    );

    // Mock providers for GraphQL schema
    when(() => mockContext.read<String>()).thenReturn(mockServerMessage);
    when(() => mockContext.read<AddressModel>()).thenReturn(mockAddress);
  });

  group('POST /graphql', () {
    test('responds with 200 and user data for users query', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => {'query': '{ users { name age } }'},
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = await response.body();
      expect(body, contains('data'));
      expect(body, contains('users'));
    });

    test('responds with 200 for findUser query with id argument', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => {'query': '{ findUser(id: 1) { name age } }'},
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = await response.body();
      expect(body, contains('data'));
      expect(body, contains('findUser'));
    });

    test('responds with 200 for nested address query', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => {
          'query': '{ users { name address { street number zipCode } } }',
        },
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = await response.body();
      expect(body, contains('data'));
      expect(body, contains('address'));
    });

    test('responds with 200 when variables are provided', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => {
          'query': '{ findUser(id: 1) { name } }',
          'variables': <String, dynamic>{},
        },
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
    });

    test('responds with 400 when query field is missing', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => {'notQuery': 'some value'},
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.badRequest));
      expect(
        response.body(),
        completion(equals('Missing "query" field in JSON.')),
      );
    });

    test('responds with 400 when body is not a Map', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.post);
      when(() => mockRequest.json()).thenAnswer(
        (_) async => 'invalid body',
      );

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });
  });

  group('Error 405', () {
    test('returns 405 if method is GET', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.get);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('returns 405 if method is PUT', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.put);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('returns 405 if method is PATCH', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.patch);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('returns 405 if method is DELETE', () async {
      // Arrange
      when(() => mockRequest.method).thenReturn(.delete);

      // Act
      final response = await route.onRequest(mockContext);

      // Assert
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });
  });
}
