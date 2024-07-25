import 'package:fistikpazar/screen/adressedit.dart';
import 'package:flutter/material.dart';
import 'package:fistikpazar/models/adress_model.dart';
import 'package:fistikpazar/screen/adressadd.dart';
import 'package:fistikpazar/services/adress_services.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<List<Addresses>> futureAddresses;
  List<int> selectedAddresses = [];
  bool showCheckboxes = false;

  @override
  void initState() {
    super.initState();
    futureAddresses = AddressService().getAllAddresses();
  }

  void _editAddress(Addresses address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAddressScreen(address: address)),
    );

    if (result != null && result) {
      setState(() {
        futureAddresses = AddressService().getAllAddresses();
      });
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    try {
      await AddressService().deleteAddress(addressId);
      setState(() {
        futureAddresses = AddressService().getAllAddresses();
      });
      print('Silinecek adres ID: $addressId');
    } catch (e) {
      print('Adres silinirken bir hata oluştu: $e');
    }
  }

  Future<void> _deleteSelectedAddresses() async {
    for (int addressId in selectedAddresses) {
      await _deleteAddress(addressId);
    }
    setState(() {
      selectedAddresses.clear();
      showCheckboxes = false;
    });
  }

  void _navigateToAddAddressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddressScreen()),
    ).then((value) {
      if (value != null && value) {
        setState(() {
          futureAddresses = AddressService().getAllAddresses();
        });
      }
    });
  }

  void _onLongPress(Addresses address) {
    setState(() {
      showCheckboxes = true;
      selectedAddresses.add(address.adressId!);
    });
  }

  void _onTap(Addresses address) {
    if (showCheckboxes) {
      setState(() {
        if (selectedAddresses.contains(address.adressId)) {
          selectedAddresses.remove(address.adressId);
        } else {
          selectedAddresses.add(address.adressId!);
        }
      });
    }
  }

  void _cancelSelection() {
    setState(() {
      showCheckboxes = false;
      selectedAddresses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 240, 219),
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Adreslerim',
            style: TextStyle(
              fontFamily:
                  'Yellowtail-Regular.ttf', // Kullanmak istediğiniz font ailesi
              fontSize: 25.0, // Yazı boyutu
              fontWeight: FontWeight.bold, // Yazı kalınlığı
              color: Colors.black, // Yazı rengi
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          if (showCheckboxes)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedAddresses,
            ),
          if (showCheckboxes)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _cancelSelection,
            ),
        ],
      ),
      body: FutureBuilder<List<Addresses>>(
        future: futureAddresses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Adres bulunamadı.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final address = snapshot.data![index];
                return Card(
                  color: Color.fromARGB(255, 255, 240, 219),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    onLongPress: () => _onLongPress(address),
                    onTap: () => _onTap(address),
                    leading: showCheckboxes
                        ? Checkbox(
                            value: selectedAddresses.contains(address.adressId),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedAddresses.add(address.adressId!);
                                } else {
                                  selectedAddresses.remove(address.adressId);
                                }
                              });
                            },
                          )
                        : null,
                    title: Text('${address.province}, ${address.township}'),
                    subtitle: Text(address.fullAddress ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editAddress(address),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteAddress(address.adressId!),
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
  onPressed: _navigateToAddAddressScreen,
  backgroundColor: Color.fromARGB(255, 255, 240, 219), // Arka plan rengini mavi yapar
  foregroundColor: Colors.black, // İkonun rengini sarı yapar
  child: Icon(Icons.add),
),

    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddressScreen(),
  ));
}
