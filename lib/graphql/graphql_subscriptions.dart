import 'dart:async';

import 'package:dart_frog_backend_demo/model/user/user_model.dart';

class GraphQLSubscriptions {
  GraphQLSubscriptions._();

  static final GraphQLSubscriptions _instance = GraphQLSubscriptions._();
  static GraphQLSubscriptions get instance => _instance;

  final _userCreatedController = StreamController<UserModel>.broadcast();
  final _userUpdatedController = StreamController<UserModel>.broadcast();
  final _userDeletedController = StreamController<int>.broadcast();

  Stream<UserModel> get onUserCreated => _userCreatedController.stream;

  Stream<UserModel> get onUserUpdated => _userUpdatedController.stream;

  Stream<int> get onUserDeleted => _userDeletedController.stream;

  void notifyUserCreated(UserModel user) {
    _userCreatedController.add(user);
  }

  void notifyUserUpdated(UserModel user) {
    _userUpdatedController.add(user);
  }

  void notifyUserDeleted(int id) {
    _userDeletedController.add(id);
  }

  Stream<int> countdown(int from) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (i) => from - i,
    ).take(from + 1);
  }

  Future<void> dispose() async {
    await _userCreatedController.close();
    await _userUpdatedController.close();
    await _userDeletedController.close();
  }
}
