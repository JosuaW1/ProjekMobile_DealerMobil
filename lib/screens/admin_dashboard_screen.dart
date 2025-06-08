import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/mobil_provider.dart';
import '../providers/order_provider.dart';
import '../utils/navigation_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mobilProvider = Provider.of<MobilProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    userProvider.fetchUsers();
    mobilProvider.fetchMobil();
    orderProvider.fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final mobilProvider = Provider.of<MobilProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final currentUser = authProvider.currentUser;
    final totalUsers = userProvider.users.length;
    final totalMobil = mobilProvider.mobilList.length;
    final totalOrders = orderProvider.orders.length;
    final adminCount = userProvider.getUsersByRole('admin').length;
    final userCount = userProvider.getUsersByRole('user').length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[600]!, Colors.red[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang, Admin!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  currentUser?.namaLengkap ?? 'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Panel kontrol untuk mengelola sistem dealer mobil',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Statistics Overview
              Text(
                'Statistik Sistem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio:
                    1.6, // Increased from 1.5 to 1.6 for more height
                children: [
                  _buildStatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => NavigationHelper.goToAdminUsers(context),
                  ),
                  _buildStatCard(
                    title: 'Total Mobil',
                    value: totalMobil.toString(),
                    icon: Icons.directions_car,
                    color: Colors.green,
                    onTap: () => NavigationHelper.goToAdminMobil(context),
                  ),
                  _buildStatCard(
                    title: 'Total Orders',
                    value: totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                    onTap: () => NavigationHelper.goToAdminOrders(context),
                  ),
                  _buildStatCard(
                    title: 'Admin Count',
                    value: adminCount.toString(),
                    icon: Icons.admin_panel_settings,
                    color: Colors.red,
                    onTap: () => NavigationHelper.goToAdminUsers(context),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Quick Actions
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              // Action Cards
              Column(
                children: [
                  _buildActionCard(
                    title: 'Kelola Users',
                    subtitle: 'Manage users, ubah role, hapus akun',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                    onTap: () => NavigationHelper.goToAdminUsers(context),
                  ),
                  SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Kelola Mobil',
                    subtitle: 'Tambah, edit, hapus data mobil',
                    icon: Icons.directions_car_outlined,
                    color: Colors.green,
                    onTap: () => NavigationHelper.goToAdminMobil(context),
                  ),
                  SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Kelola Orders',
                    subtitle: 'Monitor dan kelola semua pesanan',
                    icon: Icons.shopping_cart_outlined,
                    color: Colors.orange,
                    onTap: () => NavigationHelper.goToAdminOrders(context),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Recent Activity (placeholder)
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fitur monitoring aktivitas akan segera hadir',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(10.0), // Reduced from 12.0 to 10.0
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26, // Reduced from 28 to 26
                color: color,
              ),
              SizedBox(height: 4), // Reduced from 6 to 4
              Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Reduced from 22 to 20
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 2), // Keep at 2
              Flexible(
                // Added Flexible to prevent overflow
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, // Reduced from 11 to 10
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
