import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductFiltersDialog extends StatefulWidget {
  ProductFiltersDialog({Key? key}) : super(key: key);

  @override
  _ProductFiltersDialogState createState() => _ProductFiltersDialogState();
}

class _ProductFiltersDialogState extends State<ProductFiltersDialog> {
  List<String> _selectedCategories = [];
  String? _selectedProductSize;
  double? _selectedPrice = 50.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kategori:'),
            DropdownButton<String>(
              // Kategori seçenekleri
              value: null,
              onChanged: (value) {
                setState(() {
                  if (_selectedCategories.contains(value!)) {
                    _selectedCategories.remove(value);
                  } else {
                    _selectedCategories.add(value);
                  }
                });
              },
              items: [
                'Tümü',
                'Siirt Fıstığı',
                'Antep Fıstığı',
                'Ceviz',
                'Fındık',
                'Elma',
                'Badem',
                'Yer Fıstığı',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Ürün Boyutu:'),
            DropdownButton<String>(
              // Ürün boyutu seçenekleri
              value: 'Tümü',
              onChanged: (value) {
                setState(() {
                  _selectedProductSize = value;
                });
              },
              items: [
                'Tümü',
                'Küçük',
                'Orta',
                'Büyük',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Fiyat Aralığı:'),
            Slider(
              // Fiyat aralığı seçeneği
              min: 0,
              max: 100,
              divisions: 100,
              label: 'Fiyat: ',
              onChanged: (double value) {
                setState(() {
                  _selectedPrice = value;
                });
              },
              value: 50,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Tüm filtreleme seçeneklerini kullanarak API'ye istek gönder
                _applyFilters(context);
              },
              child: const Text('Uygula'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _applyFilters(BuildContext context) async {
    // API isteği oluştur
    var url = Uri.parse("http://fruitmanagement.softsense.com.tr/api/Customer/GetAllProduct");
    var response = await http.post(
      url,
      body: {
        'categories': _selectedCategories.join(','), // Birden çok kategori seçeneği
        'productSize': _selectedProductSize ?? 'Tümü',
        'price': _selectedPrice.toString(),
      },
    );

    // API'den gelen yanıtı işle ve widget'ı güncelle
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Güncelleme işlemleri
    } else {
      // Hata durumunda kullanıcıya bildir
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: const Text('Ürünler getirilirken bir hata oluştu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }
}
