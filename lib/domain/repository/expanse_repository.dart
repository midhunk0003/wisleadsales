import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/expanse_model/expanse_model.dart';
import 'package:wisdeals/data/model/expanse_model/expense_travel_type_model/expense_travel_type_model.dart';
import 'package:wisdeals/data/model/expanse_model/expenses_payment_mode_model/expenses_payment_mode_model.dart';

abstract class ExpanseRepository {
  Future<Either<Failure, Success>> addExpanse(
    String? token,
    String? clientName,
    String? companyName,
    String? expanseTypeId,
    String? amount,
    String? paymentModeId,
    String? file,
    String? note,
  );
  Future<Either<Failure, ExpanseModel>> getExpanse(
    String? token,
    String? status,
  );

  Future<Either<Failure, Success>> updateExpanse(
    String? token,
    String? id,
    String? clientName,
    String? companyName,
    String? expanseTypeId,
    String? amount,
    String? paymentModeId,
    String? file,
    String? note,
  );

  Future<Either<Failure, List<ExpenseTravelData>>> getExpenseTravelType(
    String? token,
  );
  Future<Either<Failure, List<ExpensesPaymentModeList>?>> getExpensePaymentMode(
    String? token,
  );
}
