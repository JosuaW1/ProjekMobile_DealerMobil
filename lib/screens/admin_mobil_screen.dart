import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mobil_provider.dart';
import '../models/models.dart';
import '../services/currency_service.dart';

class AdminMobilScreen extends StatefulWidget {
  @override
  _AdminMobilScreenState createState() => _AdminMobilScreenState();
}

class _AdminMobilScreenState extends State<AdminMobilScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMobil();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMobil() {
    final mobilProvider = Provider.of<MobilProvider>(context, listen: false);
    mobilProvider.fetchMobil();
  }

  @override
  Widget build(BuildContext context) {
    final mobilProvider = Provider.of<MobilProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Kelola Mobil'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddMobilDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMobil,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.green[700],
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

          // Stats Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Mobil', mobilProvider.mobilList.length),
                _buildStatItem(
                    'Hasil Pencarian', mobilProvider.mobilList.length),
              ],
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
                            return _buildMobilCard(mobil);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMobilDialog,
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
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
            color: Colors.green[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada mobil',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan mobil pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddMobilDialog,
            icon: Icon(Icons.add),
            label: Text('Tambah Mobil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilCard(Mobil mobil) {
    double priceInIDR = CurrencyService.parseIndonesianPrice(mobil.harga);
    String formattedPriceIDR =
        CurrencyService.formatCurrency(priceInIDR, 'IDR');

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
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12),
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
                      Text(
                        mobil.merek,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    ],
                  ),
                ),
                Text(
                  'ID: ${mobil.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Price Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[700], size: 20),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga Original: ${mobil.harga}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        formattedPriceIDR,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditMobilDialog(mobil),
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
                    onPressed: () => _deleteMobil(mobil),
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
          title: Text('Tambah Mobil Baru'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Mobil',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _merekController,
                    decoration: InputDecoration(
                      labelText: 'Merek',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Merek tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _tahunController,
                    decoration: InputDecoration(
                      labelText: 'Tahun Produksi',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _hargaController,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: 'Contoh: 800 juta, 1.2 miliar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    nama: _namaController.text.trim(),
                    merek: _merekController.text.trim(),
                    tahunProduksi: _tahunController.text.trim(),
                    harga: _hargaController.text.trim(),
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
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
                    decoration: InputDecoration(
                      labelText: 'Nama Mobil',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _merekController,
                    decoration: InputDecoration(
                      labelText: 'Merek',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Merek tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _tahunController,
                    decoration: InputDecoration(
                      labelText: 'Tahun Produksi',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _hargaController,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: 'Contoh: 800 juta, 1.2 miliar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    nama: _namaController.text.trim(),
                    merek: _merekController.text.trim(),
                    tahunProduksi: _tahunController.text.trim(),
                    harga: _hargaController.text.trim(),
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
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
          content: Text(
              'Apakah Anda yakin ingin menghapus ${mobil.nama}?\n\nTindakan ini tidak dapat dibatalkan.'),
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
