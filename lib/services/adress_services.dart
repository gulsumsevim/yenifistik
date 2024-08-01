import 'dart:convert';
import 'package:fistikpazar/models/adress_model.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:http/http.dart' as http;

class AddressService {
  static const String apiUrl = "https://api.fistikpazar.com/api/Address/GetAddress";
  static const String updateUrl = "https://api.fistikpazar.com/api/Address/UpdateAddress";
  static const String deleteUrl = "https://api.fistikpazar.com/api/Address/DeleteAddress";

  Future<List<Addresses>> getAllAddresses() async {
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
        if (jsonData != null && jsonData["addresses"] != null) {
          List<Addresses> addresses = (jsonData["addresses"] as List)
              .map((item) => Addresses.fromJson(item))
              .toList();
          return addresses;
        } else {
          throw Exception('Adresler bulunamadı veya yanıtta hata var.');
        }
      } else {
        throw Exception('HTTP isteği başarısız oldu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Adresler yüklenemedi: $e');
    }
  }

  Future<void> updateAddress(int addressId, int provinceId, int townshipId, String fullAddress) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final Map<String, dynamic> requestData = {
        'addressId': addressId,
        'provinceId': provinceId,
        'townshipId': townshipId,
        'fullAddress': fullAddress,
      };

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('Adres başarıyla güncellendi.');
      } else {
        throw Exception('Adres güncellenirken bir hata oluştu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Adres güncellenemedi: $e');
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      final String? _token = await ApiService.getToken();
      if (_token == null) {
        throw Exception('Token alınamadı');
      }

      final Map<String, dynamic> requestData = {
        'addressId': addressId,
      };

      final response = await http.put(
        Uri.parse(deleteUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('Adres başarıyla silindi.');
      } else {
        throw Exception('Adres silinirken bir hata oluştu, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Adres silinemedi: $e');
    }
  }


  
}
