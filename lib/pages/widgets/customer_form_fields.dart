import 'package:flutter/material.dart';

import 'customer_name_fields.dart';
import 'customer_contact_fields.dart';

class CustomerFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController prefix;
  final TextEditingController firstName;
  final TextEditingController middleName;
  final TextEditingController lastName;
  final TextEditingController mobile;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController country;
  final TextEditingController zip;

  const CustomerFormFields({
    Key? key,
    required this.formKey,
    required this.prefix,
    required this.firstName,
    required this.middleName,
    required this.lastName,
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
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomerNameFields(
            prefix: prefix,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
          ),
          CustomerContactFields(
            mobile: mobile,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            city: city,
            state: state,
            country: country,
            zip: zip,
          ),
        ],
      ),
    );
  }
}