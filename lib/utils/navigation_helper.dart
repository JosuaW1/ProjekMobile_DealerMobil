import 'package:flutter/material.dart';

class NavigationHelper {
  // Main Navigation Routes
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String mobilList = '/mobil_list';
  static const String orderHistory = '/order_history';

  // Admin Routes (will be added later)
  static const String adminDashboard = '/admin_dashboard';
  static const String adminUsers = '/admin_users';
  static const String adminMobil = '/admin_mobil';
  static const String adminOrders = '/admin_orders';
  static const String sensorDemo = '/sensor_demo';

  // Navigation Methods
  static void goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void goToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void goToMain(BuildContext context) {
    Navigator.pushReplacementNamed(context, main);
  }

  static void goToMobilList(BuildContext context) {
    Navigator.pushNamed(context, mobilList);
  }

  static void goToOrderHistory(BuildContext context) {
    Navigator.pushNamed(context, orderHistory);
  }

  static void goToAdminDashboard(BuildContext context) {
    Navigator.pushNamed(context, adminDashboard);
  }

  static void goToAdminUsers(BuildContext context) {
    Navigator.pushNamed(context, adminUsers);
  }

  static void goToAdminMobil(BuildContext context) {
    Navigator.pushNamed(context, adminMobil);
  }

  static void goToAdminOrders(BuildContext context) {
    Navigator.pushNamed(context, adminOrders);
  }

  static void goToSensorDemo(BuildContext context) {
    Navigator.pushNamed(context, sensorDemo);
  }

  // Helper method to go back with result
  static void goBackWithResult(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  // Helper method to clear stack and go to specific route
  static void clearStackAndGoTo(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (Route<dynamic> route) => false,
    );
  }

  // Helper method to show custom page
  static void goToCustomPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Helper method for modal bottom sheet navigation
  static void showBottomSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: content,
      ),
    );
  }

  // Helper method for full screen dialog
  static void showFullScreenDialog(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: true,
      ),
    );
  }
}
