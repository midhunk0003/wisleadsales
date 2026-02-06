import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/report_model/report_model.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportModel>> getReport(
    String? token,
    String? type,
    String? range,
    String? startDate,
    String? endDate,
  );
}
