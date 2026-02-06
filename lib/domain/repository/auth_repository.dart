import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/login_model/login_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginModel>> login(
    String? email,
    String? password,
    String? fcmToken,
  );
}
