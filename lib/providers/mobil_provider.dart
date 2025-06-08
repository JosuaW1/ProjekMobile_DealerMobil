import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MobilProvider with ChangeNotifier {
  List<Mobil> _mobilList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Mobil> get mobilList => _searchQuery.isEmpty
      ? _mobilList
      : _mobilList
          .where((mobil) =>
              mobil.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              mobil.merek.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> fetchMobil() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mobilList = await ApiService.getMobil();
    } catch (e) {
      print('Error fetching mobil: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addMobil(Mobil mobil) async {
    try {
      bool success = await ApiService.createMobil(mobil);
      if (success) {
        await fetchMobil(); // Refresh list
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMobil(int id, Mobil mobil) async {
    try {
      bool success = await ApiService.updateMobil(id, mobil);
      if (success) {
        await fetchMobil(); // Refresh list
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMobil(int id) async {
    try {
      bool success = await ApiService.deleteMobil(id);
      if (success) {
        await fetchMobil(); // Refresh list
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
