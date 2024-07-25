import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:fistikpazar/screen/my_advisors_screen.dart';
import 'package:fistikpazar/services/login_services.dart';
import 'package:fistikpazar/models/lands_model.dart';

class FieldStatisticsScreen extends StatefulWidget {
  @override
  _FieldStatisticsScreenState createState() => _FieldStatisticsScreenState();
}

class _FieldStatisticsScreenState extends State<FieldStatisticsScreen> {
  String selectedDataType = 'Hava Durumu (Yağış)';
  String? selectedFieldName;
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
  List<String> dataTypes = [];
  List<FieldInfo> fieldNames = [];
  List<FlSpot> dataPoints = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> mqttTopics = []; // mqttTopics listesini saklamak için
  String? chartAnalysis;

  @override
  void initState() {
    super.initState();
    fetchDataTypes();
    fetchFields();
  }

  Future<void> fetchDataTypes() async {
    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/GetMqttTopicName'),
      headers: {"accept": "text/plain"},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final topics = jsonResponse['mqttTopics'];
      setState(() {
        mqttTopics = List<Map<String, dynamic>>.from(topics);
        dataTypes = topics.map<String>((topic) => topic['nameTur'].toString()).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data types');
    }
  }

  Future<void> fetchFields() async {
    try {
      List<FieldInfo> fields = await FieldService.getFields();
      setState(() {
        fieldNames = fields;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchDataPoints() async {
    if (selectedFieldName == null) return;

    final String? token = await ApiService.getToken(); // Token alınması
    if (token == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Veri türüne göre topicId belirleme
    int topicId = _getTopicIdForSelectedDataType(selectedDataType);

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/GetMqttData'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Authorization başlığı eklendi
      },
      body: jsonEncode({
        'topicId': topicId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['mqttDatas'];

      dataPoints = (data as List).mapIndexed((index, data) {
        return FlSpot(index.toDouble(), double.parse(data['payload']));
      }).toList();

      await analyzeChart();
    } else {
      // Hata mesajı işleme
      print('Failed to fetch data points: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Seçilen veri türüne göre topicId belirleme fonksiyonu
  int _getTopicIdForSelectedDataType(String selectedDataType) {
    final topic = mqttTopics.firstWhere(
      (element) => element['nameTur'] == selectedDataType,
      orElse: () => {'id': 0}
    );
    return topic['id'];
  }

  Future<void> analyzeChart() async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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', // API anahtarınızı buraya ekleyin
      },
      body: jsonEncode({
        "model": "gpt-4-turbo",
        'messages': [
          {
            'role': 'user',
            'content': 'Bu grafik verilerini analiz et: ${dataPoints.map((e) => e.y).toList()}'
          }
        ],
        'max_tokens':500,
      }),
    );

    if (response.statusCode == 200) {
    
       final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final analysis = jsonResponse['choices'][0]['message']['content'];
      setState(() {
        chartAnalysis = analysis;
      });
    } else {
      print('Failed to analyze chart: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text(
          'Arazi İstatistikleri',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // Geri dönüldüğünde true değeri gönder
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Veri Türü',
                            value: selectedDataType,
                            items: dataTypes,
                            onChanged: (value) {
                              setState(() {
                                selectedDataType = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Arazi Adı',
                            value: selectedFieldName,
                            items: fieldNames.map((field) => field.name).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFieldName = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Başlangıç Tarihi',
                            date: startDate,
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            label: 'Bitiş Tarihi',
                            date: endDate,
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchDataPoints,
                      child: Text('Verileri Getir'),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 240, 219),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: dataPoints.isEmpty
                          ? Container(child: Text('Grafik verisi bulunamadı'))
                          : Column(
                              children: [
                                Container(
                                  height: 300, // Grafiğin sabit yüksekliği
                                  child: LineChart(
                                    LineChartData(
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: dataPoints,
                                          isCurved: true,
                                          color: Colors.blue,
                                          barWidth: 4,
                                          dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (chartAnalysis != null)
                                  Text(
                                    'Yorum:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                if (chartAnalysis != null)
                                  Text(
                                    chartAnalysis!,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            child: Text(DateFormat('yyyy-MM-dd').format(date)),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? startDate : endDate;
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('tr', 'TR'),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }
}