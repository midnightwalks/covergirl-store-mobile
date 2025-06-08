import 'package:covergirlstore/models/contentModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://makeup-api.herokuapp.com/api/v1/products.json';

  static Future<List<ContentModel>> fetchData(String brand) async {
    if (brand.trim().isEmpty) {
      throw Exception("Brand tidak boleh kosong");
    }

    final response = await http.get(Uri.parse('$baseUrl?brand=$brand'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      // Tambahkan pengecekan jika data kosong (opsional)
      if (jsonResponse.isEmpty) {
        throw Exception("Produk tidak ditemukan untuk brand: $brand");
      }

      return jsonResponse.map((item) => ContentModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
