import 'package:camera/camera.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/FirebaseMessagingService.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
import 'package:wisdeals/core/dependence_injection.dart';
import 'package:wisdeals/data/model/expanse_model/expanse_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/firebase_options.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/presentation/provider/business_provider.dart';
import 'package:wisdeals/presentation/provider/drawer_provider.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/presentation/provider/home_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/leave_and_attendance_provider.dart';
import 'package:wisdeals/presentation/provider/meeting_provider.dart';
import 'package:wisdeals/presentation/provider/notification_provider.dart';
import 'package:wisdeals/presentation/provider/onboard_provider.dart';
import 'package:wisdeals/presentation/provider/order_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/presentation/provider/report_provider.dart';
import 'package:wisdeals/presentation/screens/attendanceandleave/attendance_and_leave_screen.dart';
import 'package:wisdeals/presentation/screens/business/add_business.dart';
import 'package:wisdeals/presentation/screens/business/business_screen.dart';
import 'package:wisdeals/presentation/screens/expanse/add_expanse_screen.dart';
import 'package:wisdeals/presentation/screens/expanse/expanse_list_screen.dart';
import 'package:wisdeals/presentation/screens/expanse/update_expanse_screen.dart';
import 'package:wisdeals/presentation/screens/home/home_screen.dart';
import 'package:wisdeals/presentation/screens/lead_screen/lead_add_screen.dart';
import 'package:wisdeals/presentation/screens/lead_screen/lead_list_screen.dart';
import 'package:wisdeals/presentation/screens/lead_screen/lead_update_screen.dart';
import 'package:wisdeals/presentation/screens/login/login_screen.dart';
import 'package:wisdeals/presentation/screens/meeting/meeting_list_screen.dart';
import 'package:wisdeals/presentation/screens/notification/notification_screen.dart';
import 'package:wisdeals/presentation/screens/onboard/onboard_screen.dart';
import 'package:wisdeals/presentation/screens/ordersandclientlist/order_single_view_screen.dart';
import 'package:wisdeals/presentation/screens/ordersandclientlist/order_update_screen.dart';
import 'package:wisdeals/presentation/screens/ordersandclientlist/orders_screen.dart';
import 'package:wisdeals/presentation/screens/profile/profile_screen.dart';
import 'package:wisdeals/presentation/screens/report/report_screen.dart';
import 'package:wisdeals/presentation/screens/setting/settings_screen.dart';
import 'package:wisdeals/presentation/screens/splash/splash_screen.dart';
import 'package:wisdeals/widgets/bottom_navbar_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUpDependenceInjection();
  final SharedPreferences pref = await SharedPreferences.getInstance();
  // await pref.clear();
  // firebase set up
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingService().initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  if (message.notification != null) {
    print('Notification Title: ${message.notification!.title}');
    print('Notification Body: ${message.notification!.body}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<HomeProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => OnboardProvider()),
        ChangeNotifierProvider(create: (_) => DrawerProvider()),
        ChangeNotifierProvider(
          create: (_) => getIt<AppUpdateVersionProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => getIt<OrderProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MeetingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LeadProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<BusinessProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ExpanseProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ReportProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProfileProvider>()),
        ChangeNotifierProvider(
          create: (_) => getIt<LeaveAndAttendanceProvider>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'wisdeal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _customPageRoute(SplashScreen());
            case '/onboardscreen':
              return _customPageRoute(OnboardScreen());
            case '/homescreen':
              return _customPageRoute(HomeScreen());
            case '/loginScreen':
              return _customPageRoute(LoginScreen());
            case '/bottomnavbarwidget':
              final args = settings.arguments as Map<String, dynamic>?;
              final int? initialInd = args?['initialIndex'] ?? 0;
              print('............ $initialInd');
              return _customPageRoute(
                BottomNavbarWidget(initialIndex: initialInd),
              );
            case '/profilescreen':
              return _customPageRoute(ProfileScreen());
            case '/settingsscreen':
              return _customPageRoute(SettingsScreen());
            case '/reportscreen':
              return _customPageRoute(ReportScreen());
            case '/ordersscreen':
              return _customPageRoute(OrdersScreen());
            case '/ordersingleviewscreen':
              assert(settings.arguments != null && settings.arguments is Map);
              final args = settings.arguments as Map;
              final Clients clientSingle = args["client"];
              print('clent : ${clientSingle}');
              return _customPageRoute(
                OrderSingleViewScreen(clientSingle: clientSingle),
              );
            case '/orderupdatescreen':
              assert(settings.arguments != null && settings.arguments is Map);
              final args = settings.arguments as Map;
              final Clients clientSingle = args["client"];
              print('clent : ${clientSingle}');
              return _customPageRoute(
                OrderUpdateScreen(clientSingle: clientSingle),
              );

            case '/meetinglistscreen':
              return _customPageRoute(MeetingListScreen());
            case '/leadlistscreen':
              return _customPageRoute(LeadListScreen());
            case '/leadaddscreen':
              return _customPageRoute(LeadAddScreen());
            case '/leadupdatescreen':
              final args = settings.arguments as LeadData?;
              return _customPageRoute(LeadUpdateScreen(leadData: args));
            case '/expanselistscreen':
              return _customPageRoute(ExpanseListScreen());
            case '/addexpansescreen':
              return _customPageRoute(AddExpanseScreen());
            case '/updateexpansescreen':
              final args = settings.arguments as ExpanseData?;
              return _customPageRoute(UpdateExpanseScreen(expanse: args));
            case '/notificationscreen':
              return _customPageRoute(NotificationScreen());
            case '/attendanceandleavescreen':
              return _customPageRoute(AttendanceAndLeaveScreen());
            case '/businessScreen':
              return _customPageRoute(BusinessScreen());
            case '/addBusiness':
              return _customPageRoute(AddBusiness());

            default:
              return null;
          }
        },
      ),
    );
  }
}

PageRouteBuilder _customPageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; // No animation
    },
    transitionDuration: Duration.zero, // Instantly switch pages
  );
}
