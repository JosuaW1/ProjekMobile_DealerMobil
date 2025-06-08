import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/mobil_provider.dart';
import '../providers/order_provider.dart';
import '../services/timezone_service.dart';
import '../services/currency_service.dart';
import '../models/models.dart';
import '../utils/navigation_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';
  String _selectedTimezone = 'WIB';
  String _selectedCurrency = 'IDR';
  Timer? _timer;
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _updateTime();
    _startTimer();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeSettings() async {
    _settingsBox = Hive.box('settings');
    _selectedTimezone =
        _settingsBox?.get('timezone', defaultValue: 'WIB') ?? 'WIB';
    _selectedCurrency =
        _settingsBox?.get('currency', defaultValue: 'IDR') ?? 'IDR';
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime =
          TimezoneService.getCurrentTimeInTimezone(_selectedTimezone);
    });
  }

  void _loadData() {
    final mobilProvider = Provider.of<MobilProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    mobilProvider.fetchMobil();
    if (authProvider.currentUser != null) {
      orderProvider.fetchUserOrders(authProvider.currentUser!.id!);
    }
  }

  void _changeTimezone(String timezone) {
    setState(() {
      _selectedTimezone = timezone;
    });
    _settingsBox?.put('timezone', timezone);
    _updateTime();
  }

  void _changeCurrency(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
    _settingsBox?.put('currency', currency);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final mobilProvider = Provider.of<MobilProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dealer Mobil'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Timezone Selector
          PopupMenuButton<String>(
            icon: Icon(Icons.access_time),
            onSelected: _changeTimezone,
            itemBuilder: (context) => TimezoneService.getSupportedTimezones()
                .map((timezone) => PopupMenuItem(
                      value: timezone,
                      child: Text(timezone),
                    ))
                .toList(),
          ),
          // Currency Selector
          PopupMenuButton<String>(
            icon: Icon(Icons.attach_money),
            onSelected: _changeCurrency,
            itemBuilder: (context) => CurrencyService.getSupportedCurrencies()
                .map((currency) => PopupMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
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
              // Welcome Card dengan Time
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
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentUser?.namaLengkap ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.account_circle,
                              color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text(
                            currentUser?.role?.toUpperCase() ?? 'USER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '$_currentTime ($_selectedTimezone)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Quick Actions
              Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.directions_car,
                      title: 'Beli Mobil',
                      subtitle: 'Lihat katalog mobil',
                      color: Colors.green,
                      onTap: () {
                        NavigationHelper.goToMobilList(context);
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.history,
                      title: 'Riwayat',
                      subtitle: 'Lihat pesanan',
                      color: Colors.orange,
                      onTap: () {
                        NavigationHelper.goToOrderHistory(context);
                      },
                    ),
                  ),
                ],
              ),

              // Admin Access (if user is admin)
              if (currentUser?.role == 'admin') ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Admin Panel',
                        subtitle: 'Kelola sistem',
                        color: Colors.red,
                        onTap: () {
                          NavigationHelper.goToAdminDashboard(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 20),

              // Statistics
              Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Mobil',
                      value: mobilProvider.mobilList.length.toString(),
                      icon: Icons.directions_car,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pesanan Saya',
                      value: orderProvider.userOrders.length.toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Recent Cars
              Text(
                'Mobil Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 12),

              // Cars List
              mobilProvider.isLoading
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : mobilProvider.mobilList.isEmpty
                      ? Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada mobil tersedia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: mobilProvider.mobilList
                              .take(3) // Show only first 3 cars
                              .map((mobil) => _buildCarCard(mobil))
                              .toList(),
                        ),

              SizedBox(height: 12),

              // View All Cars Button
              if (mobilProvider.mobilList.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      NavigationHelper.goToMobilList(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Lihat Semua Mobil'),
                  ),
                ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(Mobil mobil) {
    double priceInIDR = CurrencyService.parseIndonesianPrice(mobil.harga);
    double convertedPrice =
        CurrencyService.convertCurrency(priceInIDR, _selectedCurrency);
    String formattedPrice =
        CurrencyService.formatCurrency(convertedPrice, _selectedCurrency);

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mobil.nama,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${mobil.merek} • ${mobil.tahunProduksi}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
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
    );
  }
}
