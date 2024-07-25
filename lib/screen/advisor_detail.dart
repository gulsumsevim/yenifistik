import 'package:fistikpazar/services/advisor_services.dart';
import 'package:fistikpazar/services/lands_services.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/advisor_model.dart';
import 'package:fistikpazar/models/lands_model.dart';


class AdvisorDetailPage extends StatefulWidget {
  final Advisor advisor;

  AdvisorDetailPage({required this.advisor});

  @override
  _AdvisorDetailPageState createState() => _AdvisorDetailPageState();
}

class _AdvisorDetailPageState extends State<AdvisorDetailPage> {
  late Future<List<FieldInfo>> futureFields;
  FieldInfo? selectedField;

  @override
  void initState() {
    super.initState();
    futureFields = FieldService.getFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danışman Detayları'),
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.advisor.profileImage,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.advisor.name} ${widget.advisor.surname}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.advisor.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Hakkında:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.advisor.advisorDescription.isNotEmpty
                            ? widget.advisor.advisorDescription
                            : 'Hakkında bilgi bulunmamaktadır.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Arazi Seç',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<List<FieldInfo>>(
              future: futureFields,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Bir hata oluştu: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Arazi bulunamadı.');
                } else {
                  return DropdownButton<FieldInfo>(
                    isExpanded: true,
                    value: selectedField,
                    hint: Text('Arazi Seç'),
                    onChanged: (FieldInfo? newValue) {
                      setState(() {
                        selectedField = newValue;
                      });
                    },
                    items: snapshot.data!.map<DropdownMenuItem<FieldInfo>>((FieldInfo field) {
                      return DropdownMenuItem<FieldInfo>(
                        value: field,
                        child: Text(field.name),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedField != null) {
                  try {
                    await AdvisorService.addFieldToAdvisor(selectedField!.fieldId, widget.advisor.userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Arazi başarıyla atandı')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Arazi atama işlemi başarısız: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen bir arazi seçin')),
                  );
                }
              },
              child: Text('Araziyi Ata'),
            ),
          ],
        ),
      ),
    );
  }
}
