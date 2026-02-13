import 'package:get_it/get_it.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_repository.dart';
import 'package:wisdeals/app_update_version.dart/app_update_versionn_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/attendance_leave_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/auth_repository_implimentation.dart';
import 'package:wisdeals/data/repository_implimentation/business_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/expanse_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/home_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/lead_managment_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/notification_repository_implimentation.dart';
import 'package:wisdeals/data/repository_implimentation/order_and_client_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/profile_repository_impli.dart';
import 'package:wisdeals/data/repository_implimentation/report_repository_impli.dart';
import 'package:wisdeals/domain/repository/attendance_and_leave_repository.dart';
import 'package:wisdeals/domain/repository/auth_repository.dart';
import 'package:wisdeals/domain/repository/business_repository.dart';
import 'package:wisdeals/domain/repository/expanse_repository.dart';
import 'package:wisdeals/domain/repository/home_repository.dart';
import 'package:wisdeals/domain/repository/lead_managment_repository.dart';
import 'package:wisdeals/domain/repository/notification_repository.dart';
import 'package:wisdeals/domain/repository/order_and_client_repository.dart';
import 'package:wisdeals/domain/repository/profile_repository.dart';
import 'package:wisdeals/domain/repository/report_repository.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/presentation/provider/business_provider.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/presentation/provider/home_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/leave_and_attendance_provider.dart';
import 'package:wisdeals/presentation/provider/meeting_provider.dart';
import 'package:wisdeals/presentation/provider/notification_provider.dart';
import 'package:wisdeals/presentation/provider/order_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/presentation/provider/report_provider.dart';

final getIt = GetIt.instance;

void setUpDependenceInjection() {
  // login
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplimentation(),
  );
  // register provider
  // This is where we register our provider
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(authRepository: getIt<AuthRepository>()),
  );

  //  lead managment
  getIt.registerLazySingleton<LeadManagmentRepository>(
    () => LeadManagmentRepositoryImpli(),
  );
  // register provider
  // This is where we register our provider
  getIt.registerLazySingleton<LeadProvider>(
    () =>
        LeadProvider(leadManagmentRepository: getIt<LeadManagmentRepository>()),
  );

  //  order and client
  getIt.registerLazySingleton<OrderAndClientRepository>(
    () => OrderAndClientRepositoryImpli(),
  );
  // register provider
  // This is where we register our provider
  getIt.registerLazySingleton<OrderProvider>(
    () => OrderProvider(
      orderAndClientRepository: getIt<OrderAndClientRepository>(),
    ),
  );

  //  attendance and leave
  getIt.registerLazySingleton<AttendanceAndLeaveRepository>(
    () => AttendanceLeaveRepositoryImpli(),
  );
  // register provider
  // This is where we register our provider
  getIt.registerLazySingleton<LeaveAndAttendanceProvider>(
    () => LeaveAndAttendanceProvider(
      attendanceAndLeaveRepository: getIt<AttendanceAndLeaveRepository>(),
    ),
  );

  //  attendance and leave
  getIt.registerLazySingleton<ExpanseRepository>(
    () => ExpanseRepositoryImpli(),
  );
  // register provider
  // This is where we register our provider
  getIt.registerLazySingleton<ExpanseProvider>(
    () => ExpanseProvider(expanseRepository: getIt<ExpanseRepository>()),
  );

  //  profile
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpli(),
  );
  // profile provider
  // This is where we register our provider
  getIt.registerLazySingleton<ProfileProvider>(
    () => ProfileProvider(profileRepository: getIt<ProfileRepository>()),
  );

  //  Report
  getIt.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpli());
  // Report provider
  // This is where we register our provider
  getIt.registerLazySingleton<ReportProvider>(
    () => ReportProvider(reportRepository: getIt<ReportRepository>()),
  );

  //  Meeting provider register client and lead repositort
  // This is where we register our provider
  getIt.registerLazySingleton<MeetingProvider>(
    () => MeetingProvider(
      orderAndClientRepository: getIt<OrderAndClientRepository>(),
      leadManagmentRepository: getIt<LeadManagmentRepository>(),
    ),
  );

  //  Report
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpli());
  // Report provider
  // This is where we register our provider
  getIt.registerLazySingleton<HomeProvider>(
    () => HomeProvider(homeRepository: getIt<HomeRepository>()),
  );

  //  Report
  getIt.registerLazySingleton<AppUpdateVersionRepository>(
    () => AppUpdateVersionnRepositoryImpli(),
  );
  // Report provider
  // This is where we register our provider
  getIt.registerLazySingleton<AppUpdateVersionProvider>(
    () => AppUpdateVersionProvider(
      appUpdateVersionRepository: getIt<AppUpdateVersionRepository>(),
    ),
  );

  //  Report
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImplimentation(),
  );
  // Report provider
  // This is where we register our provider
  getIt.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(
      notificationRepository: getIt<NotificationRepository>(),
    ),
  );

  //  Business
  getIt.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpli(),
  );
  // Business provider
  // This is where we register our provider
  getIt.registerLazySingleton<BusinessProvider>(
    () => BusinessProvider(businessRepository: getIt<BusinessRepository>()),
  );
}
