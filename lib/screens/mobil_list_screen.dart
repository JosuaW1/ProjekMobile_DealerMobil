import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../providers/mobil_provider.dart';
import '../providers/auth_provider.dart';
import '../services/currency_service.dart';
import '../models/models.dart';
import 'mobil_detail_screen.dart';

class MobilListScreen extends StatefulWidget {
  @override
  _MobilListScreenState createState() => _MobilListScreenState();
}

class _MobilListScreenState extends State<MobilListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCurrency = 'IDR';
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _loadMobil();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeSettings() async {
    _settingsBox = Hive.box('settings');
    _selectedCurrency =
        _settingsBox?.get('currency', defaultValue: 'IDR') ?? 'IDR';
    setState(() {});
  }

  void _loadMobil() {
    final mobilProvider = Provider.of<MobilProvider>(context, listen: false);
    mobilProvider.fetchMobil();
  }

  void _changeCurrency(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
    _settingsBox?.put('currency', currency);
  }

  @override
  Widget build(BuildContext context) {
    final mobilProvider = Provider.of<MobilProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Daftar Mobil'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
          // Admin: Add Car Button
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddMobilDialog();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue[700],
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                mobilProvider.setSearchQuery(value);
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari mobil...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          mobilProvider.setSearchQuery('');
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

          // Mobil List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadMobil();
              },
              child: mobilProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : mobilProvider.mobilList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16.0),
                          itemCount: mobilProvider.mobilList.length,
                          itemBuilder: (context, index) {
                            final mobil = mobilProvider.mobilList[index];
                            return _buildMobilCard(mobil, isAdmin);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Tidak ada mobil tersedia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Silakan coba lagi nanti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilCard(Mobil mobil, bool isAdmin) {
    double priceInIDR = CurrencyService.parseIndonesianPrice(mobil.harga);
    double convertedPrice =
        CurrencyService.convertCurrency(priceInIDR, _selectedCurrency);
    String formattedPrice =
        CurrencyService.formatCurrency(convertedPrice, _selectedCurrency);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MobilDetailScreen(mobil: mobil),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Car Image Placeholder
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(width: 16),

              // Car Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mobil.nama,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mobil.merek,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Tahun ${mobil.tahunProduksi}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdmin) ...[
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[700]),
                      onPressed: () => _showEditMobilDialog(mobil),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[700]),
                      onPressed: () => _deleteMobil(mobil),
                    ),
                  ] else ...[
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMobilDialog() {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController();
    final _merekController = TextEditingController();
    final _tahunController = TextEditingController();
    final _hargaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Mobil'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(labelText: 'Nama Mobil'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _merekController,
                    decoration: InputDecoration(labelText: 'Merek'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Merek tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _tahunController,
                    decoration: InputDecoration(labelText: 'Tahun Produksi'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _hargaController,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      hintText: 'Contoh: 800 juta, 1.2 miliar',
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Harga tidak boleh kosong'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Mobil newMobil = Mobil(
                    nama: _namaController.text,
                    merek: _merekController.text,
                    tahunProduksi: _tahunController.text,
                    harga: _hargaController.text,
                  );

                  final mobilProvider =
                      Provider.of<MobilProvider>(context, listen: false);
                  bool success = await mobilProvider.addMobil(newMobil);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Mobil berhasil ditambahkan'
                          : 'Gagal menambahkan mobil'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMobilDialog(Mobil mobil) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: mobil.nama);
    final _merekController = TextEditingController(text: mobil.merek);
    final _tahunController = TextEditingController(text: mobil.tahunProduksi);
    final _hargaController = TextEditingController(text: mobil.harga);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Mobil'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(labelText: 'Nama Mobil'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _merekController,
                    decoration: InputDecoration(labelText: 'Merek'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Merek tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _tahunController,
                    decoration: InputDecoration(labelText: 'Tahun Produksi'),
                    validator: (value) => value?.isEmpty == true
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  TextFormField(
                    controller: _hargaController,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      hintText: 'Contoh: 800 juta, 1.2 miliar',
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Harga tidak boleh kosong'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Mobil updatedMobil = Mobil(
                    id: mobil.id,
                    nama: _namaController.text,
                    merek: _merekController.text,
                    tahunProduksi: _tahunController.text,
                    harga: _hargaController.text,
                  );

                  final mobilProvider =
                      Provider.of<MobilProvider>(context, listen: false);
                  bool success =
                      await mobilProvider.updateMobil(mobil.id!, updatedMobil);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Mobil berhasil diperbarui'
                          : 'Gagal memperbarui mobil'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMobil(Mobil mobil) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Mobil'),
          content: Text('Apakah Anda yakin ingin menghapus ${mobil.nama}?'),
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
      final mobilProvider = Provider.of<MobilProvider>(context, listen: false);
      bool success = await mobilProvider.deleteMobil(mobil.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Mobil berhasil dihapus' : 'Gagal menghapus mobil'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
