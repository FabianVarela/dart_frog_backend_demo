import 'dart:async';

import 'package:dart_frog_backend_demo/cubit/color/color_manager_cubit.dart';
import 'package:dart_frog_backend_demo/model/color/color_model.dart';
import 'package:test/test.dart';

void main() {
  group('ColorManagerCubit', () {
    late ColorManagerCubit cubit;

    setUp(() {
      cubit = ColorManagerCubit();
    });

    tearDown(() {
      unawaited(cubit.close());
    });

    group('initial state', () {
      test('has default color (128, 128, 128)', () {
        expect(cubit.state.currentColor.red, equals(128));
        expect(cubit.state.currentColor.green, equals(128));
        expect(cubit.state.currentColor.blue, equals(128));
      });

      test('has empty users list', () {
        expect(cubit.state.users, isEmpty);
      });

      test('has empty color history', () {
        expect(cubit.state.colorHistory, isEmpty);
      });
    });

    group('userConnected', () {
      test('adds user to users list', () {
        // Act
        cubit.userConnected('user-1');

        // Assert
        expect(cubit.state.users, contains('user-1'));
        expect(cubit.state.users.length, equals(1));
      });

      test('adds multiple users to users list', () {
        // Act
        cubit
          ..userConnected('user-1')
          ..userConnected('user-2')
          ..userConnected('user-3');

        // Assert
        expect(cubit.state.users.length, equals(3));
        expect(cubit.state.users, containsAll(['user-1', 'user-2', 'user-3']));
      });
    });

    group('userDisconnected', () {
      test('removes user from users list', () {
        // Arrange
        cubit
          ..userConnected('user-1')
          ..userConnected('user-2')
          // Act
          ..userDisconnected('user-1');

        // Assert
        expect(cubit.state.users, isNot(contains('user-1')));
        expect(cubit.state.users, contains('user-2'));
        expect(cubit.state.users.length, equals(1));
      });

      test('does nothing if user is not in list', () {
        // Arrange
        cubit
          ..userConnected('user-1')
          // Act
          ..userDisconnected('non-existent-user');

        // Assert
        expect(cubit.state.users.length, equals(1));
        expect(cubit.state.users, contains('user-1'));
      });
    });

    group('updateColor', () {
      test('updates color and adds to history', () {
        // Arrange
        const newColor = (red: 255, green: 0, blue: 0);

        // Act
        cubit.updateColor(newColor, 'user-1');

        // Assert
        expect(cubit.state.colorHistory.length, equals(1));
        expect(cubit.state.colorHistory.first.color, equals(newColor));
        expect(cubit.state.colorHistory.first.lastUpdateBy, equals('user-1'));
      });

      test('limits color history to maxRecentHistory', () {
        // Arrange & Act
        for (var i = 0; i < 15; i++) {
          cubit.updateColor((red: i * 10, green: i * 10, blue: i * 10), 'user');
        }

        // Assert
        expect(
          cubit.state.colorHistory.length,
          equals(ColorManagerCubit.maxRecentHistory),
        );
      });

      test('calculates weighted average color from history', () {
        // Act
        cubit
          ..updateColor((red: 0, green: 0, blue: 0), 'user-1')
          ..updateColor((red: 255, green: 255, blue: 255), 'user-2');

        // Assert
        expect(cubit.state.currentColor.red, greaterThan(0));
        expect(cubit.state.currentColor.red, lessThan(255));
      });
    });

    group('resetColor', () {
      test('resets color to default (128, 128, 128)', () {
        // Arrange
        cubit
          ..updateColor((red: 255, green: 0, blue: 0), 'user-1')
          // Act
          ..resetColor();

        // Assert
        expect(cubit.state.currentColor.red, equals(128));
        expect(cubit.state.currentColor.green, equals(128));
        expect(cubit.state.currentColor.blue, equals(128));
      });

      test('clears color history', () {
        // Arrange
        cubit
          ..updateColor((red: 255, green: 0, blue: 0), 'user-1')
          ..updateColor((red: 0, green: 255, blue: 0), 'user-2')
          // Act
          ..resetColor();

        // Assert
        expect(cubit.state.colorHistory, isEmpty);
      });

      test('preserves connected users after reset', () {
        // Arrange
        cubit
          ..userConnected('user-1')
          ..updateColor((red: 255, green: 0, blue: 0), 'user-1')
          // Act
          ..resetColor();

        // Assert
        expect(cubit.state.users, contains('user-1'));
      });
    });
  });

  group('ColorMixModel', () {
    test('toJson returns correct structure', () {
      // Arrange
      final model = ColorMixModel(
        currentColor: (red: 100, green: 150, blue: 200),
        users: ['user-1', 'user-2'],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json, containsPair('users', ['user-1', 'user-2']));
    });

    test('copyWith creates new instance with updated values', () {
      // Arrange
      final original = ColorMixModel();

      // Act
      final updated = original.copyWith(
        currentColor: (red: 255, green: 255, blue: 255),
        users: ['new-user'],
      );

      // Assert
      expect(updated.currentColor.red, equals(255));
      expect(updated.users, contains('new-user'));
      expect(original.currentColor.red, equals(128));
    });
  });

  group('ColorModel', () {
    test('creates with default values', () {
      // Arrange & Act
      final model = ColorModel();

      // Assert
      expect(model.color.red, equals(128));
      expect(model.color.green, equals(128));
      expect(model.color.blue, equals(128));
      expect(model.lastUpdateBy, equals('system'));
    });

    test('copyWith clamps color values to 0-255', () {
      // Arrange
      final model = ColorModel();

      // Act
      final updated = model.copyWith(red: 300, green: -10, blue: 100);

      // Assert
      expect(updated.color.red, equals(255));
      expect(updated.color.green, equals(0));
      expect(updated.color.blue, equals(100));
    });
  });

  group('ColorRGB extension', () {
    test('toHexString returns correct hex format', () {
      // Arrange
      const color = (red: 255, green: 128, blue: 0);

      // Act
      final hexString = color.toHexString;

      // Assert
      expect(hexString, equals('#ff8000'));
    });

    test('toHexString pads single digit values', () {
      // Arrange
      const color = (red: 0, green: 0, blue: 0);

      // Act
      final hexString = color.toHexString;

      // Assert
      expect(hexString, equals('#000000'));
    });

    test('toHexString handles white color', () {
      // Arrange
      const color = (red: 255, green: 255, blue: 255);

      // Act
      final hexString = color.toHexString;

      // Assert
      expect(hexString, equals('#ffffff'));
    });
  });
}
