import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterOptions extends StatelessWidget {
  final VoidCallback onFilterApplied;

  const FilterOptions({super.key, required this.onFilterApplied});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                suffixIcon: Icon(Icons.search),
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              style: _textStyle(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Field Name',
            style: _textStyle(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Deck Level',
            style: _textStyle(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Platform',
            style: _textStyle(),
          ),
        ),
      ],
    );
  }

  TextStyle _textStyle() {
    return GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }
}