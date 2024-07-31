import 'package:flutter/material.dart';
import 'package:fistikpazar/models/card_model.dart';
import 'package:fistikpazar/screen/cardadd.dart';
import 'package:fistikpazar/screen/cardeditpage.dart';
import 'package:fistikpazar/services/card_services.dart';

class CardListPage extends StatefulWidget {
  @override
  _CardListPageState createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final CardService _cardService = CardService();
  Future<List<Cards>>? _creditCardFuture;

  @override
  void initState() {
    super.initState();
    _creditCardFuture = _fetchCreditCards();
  }

  Future<List<Cards>> _fetchCreditCards() async {
    try {
      final CrediCard creditCardData = await _cardService.getAllCreditcard();
      return creditCardData.cards ?? [];
    } catch (e) {
      throw Exception('Kartlar yüklenirken bir hata oluştu: $e');
    }
  }

  String _obfuscateCardNumber(String? cardNumber) {
    if (cardNumber == null || cardNumber.length < 4) {
      return '**** **** **** ****';
    }
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  String _obfuscateSecurityCode(String? securityCode) {
    if (securityCode == null || securityCode.length < 1) {
      return '*';
    }
    return '*${securityCode.substring(1)}';
  }

  void _showEditCardDialog(Cards card) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCardPage(card: card)),
    ).then((updatedCard) {
      if (updatedCard != null) {
        setState(() {
          _creditCardFuture = _fetchCreditCards();
        });
      }
    });
  }

  void _showDeleteConfirmationDialog(int cardId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Bu kartı silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop(); // Modalı kapat
              },
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop(); // Modalı kapat
                _deleteCard(cardId); // Kartı sil
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCard(int cardId) async {
    try {
      await _cardService.deleteCard(cardId);
      setState(() {
        _creditCardFuture = _fetchCreditCards();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kart silinirken bir hata oluştu: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kredi Kartları'),
      ),
      body: FutureBuilder<List<Cards>>(
        future: _creditCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Hiç kredi kartı bulunamadı.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final card = snapshot.data![index];
                return Card(
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
                          'Kredi Kartı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _obfuscateCardNumber(card.cardNumber),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              _obfuscateSecurityCode(card.securityCode),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              card.expirationDate ?? 'Geçerlilik Tarihi Yok',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showEditCardDialog(card),
                                icon: Icon(Icons.edit),
                                label: Text('Düzenle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  shadowColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showDeleteConfirmationDialog(card.cardId!),
                                icon: Icon(Icons.delete),
                                label: Text('Sil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shadowColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCardPage()),
          ).then((value) {
            if (value == true) {
              setState(() {
                _creditCardFuture = _fetchCreditCards();
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
