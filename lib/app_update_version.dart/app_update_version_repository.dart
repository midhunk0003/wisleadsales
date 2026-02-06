import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/app_update_version_model/app_update_version_model.dart';

abstract class AppUpdateVersionRepository {
  Future<Either<Failure, AppUpdateVersionModel>> getAppUpdateVersion(
    String? token,
  );
}
