import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/monthly_target_model/monthly_target_model.dart';
import 'package:wisdeals/data/model/profile_model/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileData>> getProfile(String? token);
  Future<Either<Failure, Success>> uploadProfileVerification(
    String? token,
    String? userId,
    String? photo,
    String? resumeFile,
    String? addressDocFile,
    String? accNumber,
    String? accName,
    String? ifscCode,
  );
  Future<Either<Failure, List<Target>?>> getProjectReportMonth(
    String? token,
    String? year,
  );
}
