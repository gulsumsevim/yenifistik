import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fistikpazar/models/lands_model.dart';

class FieldService {
  static const String baseUrl = 'http://fruitmanagement.softsense.com.tr/api';
  static const String getFieldInfoUrl = '$baseUrl/Farmer/GetField';
  static const String updateFieldInfoUrl = '$baseUrl/Farmer/UpdateFieldInfo';
  static const String deleteFieldUrl = '$baseUrl/Farmer/DeleteField';
  static const String addFieldUrl = '$baseUrl/Farmer/AddField';

  static Future<List<FieldInfo>> getFields() async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.get(
      Uri.parse(getFieldInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<FieldInfo> fields = [];

      if (jsonData.containsKey('fields')) {
        var fieldsJson = jsonData['fields'];

        for (var item in fieldsJson) {
          fields.add(FieldInfo.fromJson(item));
        }
      }

      return fields;
    } else {
      throw Exception('Araziler yüklenemedi! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> updateField(FieldInfo field) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.put(
      Uri.parse(updateFieldInfoUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(field.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Güncelleme başarısız oldu! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> deleteField(int fieldId) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.delete(
      Uri.parse(deleteFieldUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fieldId': fieldId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Silme işlemi başarısız oldu! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<void> addField(FieldInfo field) async {
    final String? token = await _getToken();
    if (token == null) {
      throw Exception('Token alınamadı');
    }

    final response = await http.post(
      Uri.parse(addFieldUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': field.name,
        'address': field.address,
        'area': field.area,
        'numberOfTree': field.numberOfTree,
        'location': field.location,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ekleme başarısız oldu! Hata kodu: ${response.statusCode}, Hata mesajı: ${response.body}');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
