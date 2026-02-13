import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/business_client_name_model/business_client_name_model.dart';
import 'package:wisdeals/data/model/business_list_model/business_list_model.dart';
import 'package:wisdeals/data/model/business_name_model/business_name_model.dart';

abstract class BusinessRepository {
  Future<Either<Failure, List<BusinessName>>> getBusinessName(String? token);
  Future<Either<Failure, BusinessClientNameModel>> getBusinessClientName(
    String? token,
    String? currentPage,
  );
  Future<Either<Failure, Success>> addBusiness(
    String? token,
    String? clientId,
    String? businessId,
    String? businessCost,
    String? businessType,
  );
  Future<Either<Failure, BusinessData>> getAllBusinessData(
    String? token,
    String? month,
    String? year,
    String? status,
    String? search,
    String? perpage,
  );
  Future<Either<Failure, Success>> addAmount(
    String? token,
    String? businessId,
    String? amount,
  );
  Future<Either<Failure, Success>> deleteBusiness(
    String? token,
    String? businessId,
  );
  Future<Either<Failure, Success>> deletePayment(
    String? token,
    String? paymentId,
  );
}
