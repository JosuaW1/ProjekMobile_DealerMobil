import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'providers/auth_provider.dart';
import 'providers/mobil_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/mobil_list_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_mobil_screen.dart';
import 'screens/admin_orders_screen.dart';
import 'screens/sensor_demo_screen.dart';
import 'services/database_helper.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox('settings');

  // Initialize Database
  await DatabaseHelper.instance.database;

  // Initialize Notifications
  await NotificationService.initialize();

  // Request permissions
  await Permission.location.request();
  await Permission.camera.request();
  await Permission.notification.request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MobilProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Dealer Mobil',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return auth.isLoggedIn ? MainScreen() : LoginScreen();
                },
              ),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/main': (context) => MainScreen(),
          '/mobil_list': (context) => MobilListScreen(),
          '/order_history': (context) => OrderHistoryScreen(),
          '/admin_dashboard': (context) => AdminDashboardScreen(),
          '/admin_users': (context) => AdminUsersScreen(),
          '/admin_mobil': (context) => AdminMobilScreen(),
          '/admin_orders': (context) => AdminOrdersScreen(),
          '/sensor_demo': (context) => SensorDemoScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Page Not Found'),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '404 - Page Not Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The page "${settings.name}" does not exist.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
