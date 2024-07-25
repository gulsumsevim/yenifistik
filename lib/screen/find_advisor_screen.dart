import 'package:fistikpazar/models/advisor_model.dart';
import 'package:fistikpazar/screen/advisor_detail.dart';
import 'package:fistikpazar/services/advisor_services.dart';
import 'package:flutter/material.dart';


class FindAdvisorScreen extends StatefulWidget {
  @override
  _FindAdvisorScreenState createState() => _FindAdvisorScreenState();
}

class _FindAdvisorScreenState extends State<FindAdvisorScreen> {
  late Future<List<Advisor>> futureAdvisors;

  @override
  void initState() {
    super.initState();
    futureAdvisors = AdvisorService.getAdvisors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Color.fromARGB(255, 255, 240, 219),
        title: Text('Danışman Bul'),
      ),
      body: FutureBuilder<List<Advisor>>(
        future: futureAdvisors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Danışman bulunamadı.'));
          } else {
            List<Advisor> advisors = snapshot.data!;
            return ListView.builder(
              itemCount: advisors.length,
              itemBuilder: (context, index) {
                Advisor advisor = advisors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdvisorDetailPage(advisor: advisor),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 240, 219),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(advisor.profileImage),
                            radius: 30,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${advisor.name} ${advisor.surname}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  advisor.advisorDescription,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                         
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
