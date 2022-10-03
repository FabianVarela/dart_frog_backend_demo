import 'package:dart_frog_backend_demo/model/address_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  const UserModel({
    required this.name,
    required this.age,
    required this.serverMessage,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  final String name;
  final int age;
  final String serverMessage;
  final AddressModel address;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
