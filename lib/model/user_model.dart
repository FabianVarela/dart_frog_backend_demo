import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({required this.name, required this.age});

  final String name;
  final int age;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
