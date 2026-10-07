import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
