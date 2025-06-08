import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/currency_service.dart';
import 'order_form_screen.dart';

class MobilDetailScreen extends StatefulWidget {
  final Mobil mobil;

  MobilDetailScreen({required this.mobil});

  @override
  _MobilDetailScreenState createState() => _MobilDetailScreenState();
}

class _MobilDetailScreenState extends State<MobilDetailScreen> {
  String _selectedCurrency = 'IDR';
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() async {
    _settingsBox = Hive.box('settings');
    _selectedCurrency =
        _settingsBox?.get('currency', defaultValue: 'IDR') ?? 'IDR';
    setState(() {});
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
    final currentUser = authProvider.currentUser;

    double priceInIDR =
        CurrencyService.parseIndonesianPrice(widget.mobil.harga);
    double convertedPrice =
        CurrencyService.convertCurrency(priceInIDR, _selectedCurrency);
    String formattedPrice =
        CurrencyService.formatCurrency(convertedPrice, _selectedCurrency);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Detail Mobil'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Icon(
                Icons.directions_car,
                size: 120,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 20),

            // Car Details Card
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mobil.nama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.branding_watermark,
                              size: 20, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            widget.mobil.merek,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 20, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Tahun ${widget.mobil.tahunProduksi}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Divider(),

                      SizedBox(height: 20),

                      // Price Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Harga:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedPrice,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              if (_selectedCurrency != 'IDR')
                                Text(
                                  widget.mobil.harga,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Specifications Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spesifikasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildSpecificationRow('Nama', widget.mobil.nama),
                      _buildSpecificationRow('Merek', widget.mobil.merek),
                      _buildSpecificationRow(
                          'Tahun Produksi', widget.mobil.tahunProduksi),
                      _buildSpecificationRow('Harga Asli', widget.mobil.harga),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Harga dapat berubah sewaktu-waktu. Silakan konfirmasi dengan dealer.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),

      // Buy Button
      floatingActionButton: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: currentUser != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderFormScreen(mobil: widget.mobil),
                    ),
                  );
                }
              : null,
          backgroundColor: Colors.green[700],
          icon: Icon(Icons.shopping_cart, color: Colors.white),
          label: Text(
            'Beli Sekarang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
