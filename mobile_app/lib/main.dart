import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/landing_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/scholarships_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/jago_chat_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/device_frame_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JagoApp());
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class JagoApp extends StatelessWidget {
  const JagoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'JAGO — Ministry of Tribal Affairs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) => DeviceFrameWrapper(
          navigatorKey: appNavigatorKey,
          child: child ?? const SizedBox(),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const StudentLoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/documents': (context) => const DocumentsScreen(),
          '/scholarships': (context) => const ScholarshipsScreen(),
          '/payments': (context) => const PaymentsScreen(),
          '/jago': (context) => const JagoChatScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}
