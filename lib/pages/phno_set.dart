//lib/pages/phno_set
import 'package:flutter/material.dart';

class PhoneNumberSet extends StatelessWidget {
  final String phoneNumber;

  // Add the named parameter 'phoneNumber' to the constructor
  PhoneNumberSet({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Number Set')),
      body: Center(
        child: Text('Phone Number: $phoneNumber'),
      ),
    );
  }
}