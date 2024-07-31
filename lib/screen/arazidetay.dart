import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

class ArazilerimPage extends StatefulWidget {
  @override
  _ArazilerimPageState createState() => _ArazilerimPageState();
}

class _ArazilerimPageState extends State<ArazilerimPage> {
  List<dynamic> _fields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFields();
  }

  Future<void> _fetchFields() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Advisor/GetApprovalFieldForAdvisor'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _fields = responseData['fieldInfoForAdvisors'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Araziler yüklenemedi: ${response.statusCode}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arazilerim'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _fields.isEmpty
              ? Center(child: Text('Hiç arazi bulunamadı.'))
              : ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AraziDetayPage(field: field),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arazi Adı: ${field['fieldName']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Çiftçi Adı: ${field['farmerName']}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Adres: ${field['address']}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AraziDetayPage extends StatefulWidget {
  final dynamic field;

  AraziDetayPage({required this.field});

  @override
  _AraziDetayPageState createState() => _AraziDetayPageState();
}

class _AraziDetayPageState extends State<AraziDetayPage> {
  String selectedDataType = 'Hava Durumu (Yağış)';
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
  List<String> dataTypes = [];
  List<FlSpot> dataPoints = [];
  bool _isLoading = true;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> mqttTopics = [];
  String? chartAnalysis;

  @override
  void initState() {
    super.initState();
    fetchDataTypes();
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

  Future<void> fetchDataPoints() async {
    if (widget.field['fieldName'] == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int topicId = _getTopicIdForSelectedDataType(selectedDataType);

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Farmer/GetMqttData'),
      headers: {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
    } else {
      print('Failed to fetch data points: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  int _getTopicIdForSelectedDataType(String selectedDataType) {
    final topic = mqttTopics.firstWhere(
      (element) => element['nameTur'] == selectedDataType,
      orElse: () => {'id': 0}
    );
    return topic['id'];
  }

  Future<void> analyzeChart() async {
    setState(() {
      _isAnalyzing = true;
    });

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
        'max_tokens': 500,
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

    setState(() {
      _isAnalyzing = false;
    });
  }

  void _showLocation(BuildContext context, String location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harita açılamıyor: $url')),
      );
    }
  }

  Future<void> _removeField(BuildContext context, int fieldId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Advisor/DeleteApproveFieldInfo'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/plain',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': fieldId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arazi başarıyla kaldırıldı')),
      );
      setState(() {
        Navigator.pop(context, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arazi kaldırılamadı: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arazi Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arazi Adı: ${widget.field['fieldName']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Çiftçi Adı: ${widget.field['farmerName']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Adres: ${widget.field['address']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Alan: ${widget.field['area']} m²',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ağaç Sayısı: ${widget.field['numberOfTree']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Konum: ${widget.field['location']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showLocation(context, widget.field['location']);
                        },
                        icon: Icon(Icons.location_on),
                        label: Text('Konumu Gör'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _removeField(context, widget.field['id']);
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Araziyi Kaldır'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
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
                                    height: 300,
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
                                  ElevatedButton(
                                    onPressed: _isAnalyzing ? null : analyzeChart,
                                    child: _isAnalyzing ? CircularProgressIndicator() : Text('Yorumla'),
                                  ),
                                  SizedBox(height: 16),
                                  if (chartAnalysis != null)
                                    Card(
                                      margin: EdgeInsets.only(top: 16.0),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Yorum:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              chartAnalysis!,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
