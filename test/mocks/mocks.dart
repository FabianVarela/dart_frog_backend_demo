import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:dart_frog_backend_demo/model/user_model.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestContext extends Mock implements RequestContext {}

class MockRequest extends Mock implements Request {}

class MockUri extends Mock implements Uri {}

const mockServerMessage = 'Welcome to Not The Dart Side!';
const mockAddress = AddressModel(
  street: 'Bogota',
  number: 2503,
  zipCode: 110721,
);
const mockUser = UserModel(
  name: 'Dash',
  age: 42,
  serverMessage: mockServerMessage,
  address: mockAddress,
);
