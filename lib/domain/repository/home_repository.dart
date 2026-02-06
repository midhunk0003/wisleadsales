import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/home_model/home_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDataModel>> getHomeData(String? token);
  Future<Either<Failure, Success>> clockIn(
    String? token,
    String? lat,
    String? long,
    String? km,
  );
  Future<Either<Failure, Success>> ClockOut(
    String? token,
    String? lat,
    String? long,
    String? km,
  );

  Future<Either<Failure, Success>> sendLatitudeAndLongitude(
    String? token,
    String? latitude,
    String? longitude,
  );
}
