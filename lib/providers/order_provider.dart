import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _userOrders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  List<Order> get userOrders => _userOrders;
  bool get isLoading => _isLoading;

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await DatabaseHelper.instance.getAllOrders();
    } catch (e) {
      print('Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserOrders(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userOrders = await DatabaseHelper.instance.getOrdersByUserId(userId);
    } catch (e) {
      print('Error fetching user orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder({
    required int userId,
    required int mobilId,
    required String metodePembayaran,
    required String mobilName,
  }) async {
    try {
      String tanggalPesan =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      Order newOrder = Order(
        userId: userId,
        mobilId: mobilId,
        metodePembayaran: metodePembayaran,
        tanggalPesan: tanggalPesan,
      );

      int result = await DatabaseHelper.instance.insertOrder(newOrder);

      if (result > 0) {
        // Show notification
        await NotificationService.showOrderNotification(mobilName);

        // Refresh orders
        await fetchUserOrders(userId);
        await fetchAllOrders();

        return true;
      }
      return false;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<bool> updateOrder(Order order) async {
    try {
      int result = await DatabaseHelper.instance.updateOrder(order);
      if (result > 0) {
        // Refresh orders
        await fetchUserOrders(order.userId);
        await fetchAllOrders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteOrder(int orderId, int userId) async {
    try {
      int result = await DatabaseHelper.instance.deleteOrder(orderId);
      if (result > 0) {
        // Refresh orders
        await fetchUserOrders(userId);
        await fetchAllOrders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePaymentMethod(
      int orderId, String newPaymentMethod, int userId) async {
    try {
      Order? existingOrder =
          _userOrders.firstWhere((order) => order.id == orderId);

      Order updatedOrder = Order(
        id: existingOrder.id,
        userId: existingOrder.userId,
        mobilId: existingOrder.mobilId,
        metodePembayaran: newPaymentMethod,
        tanggalPesan: existingOrder.tanggalPesan,
      );

      return await updateOrder(updatedOrder);
    } catch (e) {
      return false;
    }
  }

  List<Order> getOrdersByUser(int userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  Order? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  int getTotalOrdersCount() {
    return _orders.length;
  }

  int getUserOrdersCount(int userId) {
    return _userOrders.length;
  }
}
