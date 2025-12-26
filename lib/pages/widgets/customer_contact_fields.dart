import 'package:flutter/material.dart';

import 'customer_phone_field.dart';
import 'customer_address_fields.dart';

class CustomerContactFields extends StatelessWidget {
  final TextEditingController mobile;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController country;
  final TextEditingController zip;

  const CustomerContactFields({
    Key? key,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomerPhoneField(mobile: mobile),
        CustomerAddressFields(
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          city: city,
          state: state,
          country: country,
          zip: zip,
        ),
      ],
    );
  }
}