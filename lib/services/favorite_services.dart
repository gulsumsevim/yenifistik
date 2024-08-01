import 'dart:convert';
import 'package:fistikpazar/models/favorite_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;

class FavoritesService {
  static const String apiUrl = "https://api.fistikpazar.com/api/Customer/GetMyLikedProduct";
  static const String removeFavoriteUrl = "https://api.fistikpazar.com/api/Customer/RemoveLikeTheProduct";

  Future<List<Favorites>> getAllFavorites() async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData != null && jsonData["products"] != null) {
          List<Favorites> favorites = (jsonData["products"] as List).map((item) => Favorites.fromJson(item)).toList();
          return favorites;
        } else {
          throw Exception('Ürünler bulunamadı veya yanıtta hata var.');
        }
      } else {
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ürünler yüklenemedi: $e');
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(removeFavoriteUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'numberOfLikeTableId': productId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Favori ürünü silinemedi, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Favori ürünü silme işlemi başarısız oldu: $e');
    }
  }
}
