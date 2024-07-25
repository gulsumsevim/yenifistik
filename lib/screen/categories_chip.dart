import 'package:flutter/material.dart';


class CategoriesChip extends StatefulWidget {
  const CategoriesChip({
    Key? key,
    required this.isActive,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  final bool isActive;
  final String label;
  final void Function() onPressed;

  @override
  _CategoriesChipState createState() => _CategoriesChipState();
}

class _CategoriesChipState extends State<CategoriesChip> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _isActive = !_isActive;
        });
        widget.onPressed();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _isActive ? Colors.white : Colors.green,
        backgroundColor: _isActive ? Colors.green : Colors.white,
        side: BorderSide(color: Colors.black),
        textStyle: TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
      child: Text(widget.label),
    );
  }
}
