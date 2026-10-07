import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.locale,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        locale: locale,
      );
}
