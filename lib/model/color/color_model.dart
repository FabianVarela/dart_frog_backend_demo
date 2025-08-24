import 'package:json_annotation/json_annotation.dart';

part 'color_model.g.dart';

typedef ColorRGB = ({int red, int green, int blue});

@JsonSerializable()
class ColorMixModel {
  ColorMixModel({
    this.currentColor = const (red: 128, green: 128, blue: 128),
    this.users = const [],
    this.colorHistory = const [],
  });

  factory ColorMixModel.fromJson(Map<String, dynamic> json) =>
      _$ColorMixModelFromJson(json);

  final ColorRGB currentColor;
  final List<String> users;
  final List<ColorModel> colorHistory;

  Map<String, dynamic> toJson() => _$ColorMixModelToJson(this);

  ColorMixModel copyWith({
    ColorRGB? currentColor,
    List<String>? users,
    List<ColorModel>? colorHistory,
  }) {
    return ColorMixModel(
      currentColor: currentColor ?? this.currentColor,
      users: users ?? this.users,
      colorHistory: colorHistory ?? this.colorHistory,
    );
  }
}

@JsonSerializable()
class ColorModel {
  ColorModel({
    this.color = const (red: 128, green: 128, blue: 128),
    this.lastUpdateBy = 'system',
  }) : lastUpdate = DateTime.now();

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  final ColorRGB color;
  final String lastUpdateBy;

  @JsonKey(includeToJson: true)
  final DateTime lastUpdate;

  Map<String, dynamic> toJson() => _$ColorModelToJson(this);

  ColorModel copyWith({int? red, int? green, int? blue, String? lastUpdateBy}) {
    final newRedColor = red?.clamp(0, 255) ?? color.red;
    final newGreenColor = green?.clamp(0, 255) ?? color.green;
    final newBlueColor = blue?.clamp(0, 255) ?? color.blue;

    return ColorModel(
      color: (red: newRedColor, green: newGreenColor, blue: newBlueColor),
      lastUpdateBy: lastUpdateBy ?? this.lastUpdateBy,
    );
  }
}

extension ColorRGBX on ColorRGB {
  String get toHexString {
    final redString = red.toRadixString(16).padLeft(2, '0');
    final greenString = green.toRadixString(16).padLeft(2, '0');
    final blueString = blue.toRadixString(16).padLeft(2, '0');

    return '#$redString$greenString$blueString';
  }
}
