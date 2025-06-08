import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../providers/mobil_provider.dart';
import '../models/models.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mobilProvider = Provider.of<MobilProvider>(context, listen: false);

    orderProvider.fetchAllOrders();
    userProvider.fetchUsers();
    mobilProvider.fetchMobil();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final mobilProvider = Provider.of<MobilProvider>(context);

    // Filter orders based on search
    List<Order> filteredOrders = orderProvider.orders.where((order) {
      if (_searchController.text.isEmpty) return true;

      User? user = _getUserById(userProvider.users, order.userId);
      Mobil? mobil = _getMobilById(mobilProvider.mobilList, order.mobilId);

      String searchQuery = _searchController.text.toLowerCase();
      return (user?.namaLengkap.toLowerCase().contains(searchQuery) ?? false) ||
          (mobil?.nama.toLowerCase().contains(searchQuery) ?? false) ||
          order.metodePembayaran.toLowerCase().contains(searchQuery) ||
          order.id.toString().contains(searchQuery);
    }).toList();

    // Sort by newest first
    filteredOrders.sort((a, b) => b.tanggalPesan.compareTo(a.tanggalPesan));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Kelola Orders'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.orange[700],
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari order (nama, mobil, pembayaran, ID)...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Stats Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Orders', orderProvider.orders.length),
                _buildStatItem('Hasil Pencarian', filteredOrders.length),
                _buildStatItem(
                    'Users Aktif',
                    _getActiveUsersCount(
                        orderProvider.orders, userProvider.users)),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: orderProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16.0),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final user =
                                _getUserById(userProvider.users, order.userId);
                            final mobil = _getMobilById(
                                mobilProvider.mobilList, order.mobilId);
                            return _buildOrderCard(order, user, mobil);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pesanan akan muncul di sini setelah user melakukan pembelian',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, User? user, Mobil? mobil) {
    DateTime orderDate = DateTime.parse(order.tanggalPesan);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(orderDate);
    String timeAgo = _getTimeAgo(orderDate);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Order #${order.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Customer Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: user?.role == 'admin'
                        ? Colors.red[100]
                        : Colors.blue[100],
                    child: Icon(
                      user?.role == 'admin'
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: user?.role == 'admin'
                          ? Colors.red[700]
                          : Colors.blue[700],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.namaLengkap ?? 'User tidak ditemukan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (user != null) ...[
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            user.noTelepon,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (user?.role == 'admin')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Car Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mobil?.nama ?? 'Mobil tidak ditemukan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (mobil != null) ...[
                          Text(
                            '${mobil.merek} • ${mobil.tahunProduksi}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            mobil.harga,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Order Details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Metode Pembayaran', order.metodePembayaran),
                  _buildDetailRow('Tanggal Pesanan', formattedDate),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editOrder(order, user, mobil),
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteOrder(order, user, mobil),
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editOrder(Order order, User? user, Mobil? mobil) {
    String? selectedPaymentMethod = order.metodePembayaran;

    final List<String> paymentMethods = [
      'Transfer Bank',
      'Kartu Kredit',
      'Cash',
      'Cicilan',
      'Leasing',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Order #${order.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: ${user?.namaLengkap ?? "Unknown"}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Mobil: ${mobil?.nama ?? "Unknown"}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Metode Pembayaran',
                      border: OutlineInputBorder(),
                    ),
                    items: paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPaymentMethod != null) {
                  final orderProvider =
                      Provider.of<OrderProvider>(context, listen: false);

                  bool success = await orderProvider.updatePaymentMethod(
                    order.id!,
                    selectedPaymentMethod!,
                    order.userId,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Order berhasil diperbarui'
                          : 'Gagal memperbarui order'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );

                  if (success) _loadData();
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteOrder(Order order, User? user, Mobil? mobil) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus order ini?'),
              SizedBox(height: 12),
              Text(
                'Order ID: ${order.id}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Customer: ${user?.namaLengkap ?? "Unknown"}'),
              Text('Mobil: ${mobil?.nama ?? "Unknown"}'),
              SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      bool success = await orderProvider.deleteOrder(order.id!, order.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Order berhasil dihapus' : 'Gagal menghapus order'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) _loadData();
    }
  }

  User? _getUserById(List<User> users, int userId) {
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Mobil? _getMobilById(List<Mobil> mobilList, int mobilId) {
    try {
      return mobilList.firstWhere((mobil) => mobil.id == mobilId);
    } catch (e) {
      return null;
    }
  }

  int _getActiveUsersCount(List<Order> orders, List<User> users) {
    Set<int> activeUserIds = orders.map((order) => order.userId).toSet();
    return activeUserIds.length;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
