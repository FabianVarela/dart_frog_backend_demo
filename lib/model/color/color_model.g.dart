// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorMixModel _$ColorMixModelFromJson(Map<String, dynamic> json) =>
    ColorMixModel(
      currentColor: _$recordConvert(
        json['currentColor'],
        ($jsonValue) => (
          blue: ($jsonValue['blue'] as num).toInt(),
          green: ($jsonValue['green'] as num).toInt(),
          red: ($jsonValue['red'] as num).toInt(),
        ),
      ),
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      colorHistory: (json['colorHistory'] as List<dynamic>)
          .map((e) => ColorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ColorMixModelToJson(ColorMixModel instance) =>
    <String, dynamic>{
      'currentColor': <String, dynamic>{
        'blue': instance.currentColor.blue,
        'green': instance.currentColor.green,
        'red': instance.currentColor.red,
      },
      'users': instance.users,
      'colorHistory': instance.colorHistory,
    };

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);

ColorModel _$ColorModelFromJson(Map<String, dynamic> json) => ColorModel(
  color:
      _$recordConvert(
        json['color'],
        ($jsonValue) => (
          blue: ($jsonValue['blue'] as num).toInt(),
          green: ($jsonValue['green'] as num).toInt(),
          red: ($jsonValue['red'] as num).toInt(),
        ),
      ) ??
      (red: 128, green: 128, blue: 128),
  lastUpdateBy: json['lastUpdateBy'] as String? ?? 'system',
);

Map<String, dynamic> _$ColorModelToJson(ColorModel instance) =>
    <String, dynamic>{
      'color': <String, dynamic>{
        'blue': instance.color.blue,
        'green': instance.color.green,
        'red': instance.color.red,
      },
      'lastUpdateBy': instance.lastUpdateBy,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };
