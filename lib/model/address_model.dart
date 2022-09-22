import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  const AddressModel({
    required this.street,
    required this.number,
    required this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  final String street;
  final int number;
  final int zipCode;

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
