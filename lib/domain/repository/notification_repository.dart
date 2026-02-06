import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/notification_model/notification_model.dart';
import 'package:wisdeals/data/model/profile_model/profile_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationList>>> getNotification(
    String? token,
  );
  Future<Either<Failure, Success>> readNotification(
    String? token,
    String? notificationId,
  );
}
