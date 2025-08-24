import 'package:broadcast_bloc/broadcast_bloc.dart';
import 'package:dart_frog_backend_demo/model/color/color_model.dart';

class ColorManagerCubit extends BroadcastCubit<ColorMixModel> {
  ColorManagerCubit() : super(ColorMixModel());

  static const int maxRecentHistory = 10;

  void userConnected(String userId) {
    final updatedUsers = [...state.users, userId];
    emit(state.copyWith(users: updatedUsers));
  }

  void userDisconnected(String userId) {
    final updatedUsers = [...state.users]..remove(userId);
    emit(state.copyWith(users: updatedUsers));
  }

  void updateColor(ColorRGB color, String userId) {
    final newColorModel = ColorModel(color: color, lastUpdateBy: userId);
    final updatedColorHistory = [...state.colorHistory, newColorModel];

    if (updatedColorHistory.length > maxRecentHistory) {
      updatedColorHistory.removeAt(0);
    }

    final avgRed = _calculateAvgColor(updatedColorHistory, (e) => e.red);
    final avgGreen = _calculateAvgColor(updatedColorHistory, (e) => e.green);
    final avgBlue = _calculateAvgColor(updatedColorHistory, (e) => e.blue);

    final newColor = (red: avgRed, green: avgGreen, blue: avgBlue);
    emit(
      state.copyWith(currentColor: newColor, colorHistory: updatedColorHistory),
    );
  }

  int _calculateAvgColor(
    List<ColorModel> history,
    int Function(ColorRGB color) colorGetter,
  ) {
    if (history.isEmpty) return 128;

    var weightedSum = 0.0;
    var totalWeight = 0.0;

    for (var i = 0; i < history.length; i++) {
      final weight = i + 1 / history.length;
      weightedSum += colorGetter(history[i].color) * weight;
      totalWeight += weight;
    }

    return (weightedSum / totalWeight).round().clamp(0, 255);
  }

  void resetColor() {
    emit(
      state.copyWith(
        currentColor: (red: 128, green: 128, blue: 128),
        colorHistory: [],
      ),
    );
  }
}
