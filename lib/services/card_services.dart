import 'dart:convert';
import 'package:fistikpazar/models/card_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;

class CardService {
  final String apiUrl = 'http://fruitmanagement.softsense.com.tr/api/Card/GetCardInfo';
  final String updateCardUrl = 'http://fruitmanagement.softsense.com.tr/api/Card/UpdateCardInfo';
  final String deleteCardUrl = 'http://fruitmanagement.softsense.com.tr/api/Card/DeleteCard';
  final String addCardUrl = 'http://fruitmanagement.softsense.com.tr/api/Card/AddCardInfo';

  Future<CrediCard> getAllCreditcard() async {
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
        if (jsonData != null) {
          return CrediCard.fromJson(jsonData);
        } else {
          throw Exception('Yanıt verileri boş.');
        }
      } else {
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kartlar yüklenemedi: $e');
    }
  }

  Future<void> updateCard(Cards card) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.put(
        Uri.parse(updateCardUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cardId': card.cardId,
          'cardNumber': card.cardNumber,
          'expirationDate': card.expirationDate,
          'securityCode': card.securityCode,
          'fullName': '${card.name} ${card.surname}',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Kart güncelleme başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kart güncellenemedi: $e');
    }
  }

  Future<void> deleteCard(int cardId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.put(
        Uri.parse(deleteCardUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cardId': cardId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Kart silme başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kart silinemedi: $e');
    }
  }

  Future<void> addCard(Cards card) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final response = await http.post(
        Uri.parse(addCardUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': card.name,
          'surname': card.surname,
          'cardNumber': card.cardNumber,
          'expirationDate': card.expirationDate,
          'securityCode': card.securityCode,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Kart ekleme başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kart eklenemedi: $e');
    }
  }
}
