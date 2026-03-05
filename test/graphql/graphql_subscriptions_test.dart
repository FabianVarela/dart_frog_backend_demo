import 'dart:async';

import 'package:dart_frog_backend_demo/graphql/graphql_subscriptions.dart';
import 'package:dart_frog_backend_demo/model/address/address_model.dart';
import 'package:dart_frog_backend_demo/model/user/user_model.dart';
import 'package:test/test.dart';

void main() {
  group('GraphQLSubscriptions', () {
    test('instance returns singleton', () {
      final instance1 = GraphQLSubscriptions.instance;
      final instance2 = GraphQLSubscriptions.instance;

      expect(instance1, same(instance2));
    });

    group('onUserCreated', () {
      test('emits user when notifyUserCreated is called', () async {
        final subscriptions = GraphQLSubscriptions.instance;
        const user = UserModel(
          name: 'Test User',
          age: 25,
          serverMessage: 'Created',
          address: AddressModel(
            street: 'Test St',
            number: 123,
            zipCode: 12345,
          ),
        );

        final completer = Completer<UserModel>();
        final sub = subscriptions.onUserCreated.listen(completer.complete);

        subscriptions.notifyUserCreated(user);

        final result = await completer.future;
        expect(result.name, equals('Test User'));
        expect(result.age, equals(25));

        await sub.cancel();
      });

      test('broadcasts to multiple listeners', () async {
        final subscriptions = GraphQLSubscriptions.instance;
        const user = UserModel(
          name: 'Broadcast User',
          age: 30,
          serverMessage: 'Broadcast',
          address: AddressModel(
            street: 'Broadcast St',
            number: 456,
            zipCode: 67890,
          ),
        );

        var listener1Called = false;
        var listener2Called = false;

        final sub1 = subscriptions.onUserCreated.listen((u) {
          if (u.name == 'Broadcast User') listener1Called = true;
        });

        final sub2 = subscriptions.onUserCreated.listen((u) {
          if (u.name == 'Broadcast User') listener2Called = true;
        });

        subscriptions.notifyUserCreated(user);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);

        await sub1.cancel();
        await sub2.cancel();
      });
    });

    group('onUserUpdated', () {
      test('emits user when notifyUserUpdated is called', () async {
        final subscriptions = GraphQLSubscriptions.instance;
        const user = UserModel(
          name: 'Updated User',
          age: 35,
          serverMessage: 'Updated',
          address: AddressModel(
            street: 'Update St',
            number: 789,
            zipCode: 11111,
          ),
        );

        final completer = Completer<UserModel>();
        final sub = subscriptions.onUserUpdated.listen(completer.complete);

        subscriptions.notifyUserUpdated(user);

        final result = await completer.future;
        expect(result.name, equals('Updated User'));
        expect(result.age, equals(35));

        await sub.cancel();
      });
    });

    group('onUserDeleted', () {
      test('emits id when notifyUserDeleted is called', () async {
        final subscriptions = GraphQLSubscriptions.instance;

        final completer = Completer<int>();
        final sub = subscriptions.onUserDeleted.listen(completer.complete);

        subscriptions.notifyUserDeleted(42);

        final result = await completer.future;
        expect(result, equals(42));

        await sub.cancel();
      });
    });

    group('countdown', () {
      test('emits countdown from given number', () async {
        final subscriptions = GraphQLSubscriptions.instance;

        final values = await subscriptions.countdown(3).toList();
        expect(values, equals([3, 2, 1, 0]));
      });

      test('countdown(0) emits only 0', () async {
        final subscriptions = GraphQLSubscriptions.instance;

        final values = await subscriptions.countdown(0).toList();
        expect(values, equals([0]));
      });

      test('countdown emits at 1 second intervals', () async {
        final subscriptions = GraphQLSubscriptions.instance;
        final stopwatch = Stopwatch()..start();

        await subscriptions.countdown(2).toList();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(2000));
        expect(stopwatch.elapsedMilliseconds, lessThan(4000));
      });
    });
  });
}
