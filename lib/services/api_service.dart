import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl =
      'https://dealer-project-935996462481.us-central1.run.app';

  static Future<List<Mobil>> getMobil() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mobil'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mobil.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load mobil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Mobil> getMobilById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mobil/$id'));
      if (response.statusCode == 200) {
        return Mobil.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load mobil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> createMobil(Mobil mobil) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tambahmobil'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mobil.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateMobil(int id, Mobil mobil) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updatemobil/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mobil.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteMobil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/deletemobil/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
