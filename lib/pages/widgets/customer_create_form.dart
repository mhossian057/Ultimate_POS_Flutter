import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../apis/contact.dart';
import '../../helpers/AppTheme.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../../models/contact_model.dart';
import 'customer_form_fields.dart';

class CustomerCreateForm extends StatefulWidget {
  final VoidCallback onCustomerCreated;

  const CustomerCreateForm({
    Key? key,
    required this.onCustomerCreated,
  }) : super(key: key);

  @override
  _CustomerCreateFormState createState() => _CustomerCreateFormState();
}

class _CustomerCreateFormState extends State<CustomerCreateForm> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController prefix = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController middleName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController addressLine1 = TextEditingController();
  final TextEditingController addressLine2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController zip = TextEditingController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  @override
  void dispose() {
    prefix.dispose();
    firstName.dispose();
    middleName.dispose();
    lastName.dispose();
    mobile.dispose();
    addressLine1.dispose();
    addressLine2.dispose();
    city.dispose();
    state.dispose();
    country.dispose();
    zip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('create_contact'),
          style: themeData.appBarTheme.titleTextStyle,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CustomerFormFields(
                formKey: _formKey,
                prefix: prefix,
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                mobile: mobile,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                country: country,
                zip: zip,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 48),
          backgroundColor: themeData.colorScheme.primary,
        ),
        onPressed: _handleSubmit,
        child: Text(
          AppLocalizations.of(context)
              .translate('add_to_contact')
              .toUpperCase(),
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyLarge,
            color: themeData.colorScheme.onPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (await Helper().checkConnectivity()) {
      if (_formKey.currentState!.validate()) {
        Map newCustomer = {
          'type': 'customer',
          'prefix': prefix.text,
          'first_name': firstName.text,
          'middle_name': middleName.text,
          'last_name': lastName.text,
          'mobile': mobile.text,
          'address_line_1': addressLine1.text,
          'address_line_2': addressLine2.text,
          'city': city.text,
          'state': state.text,
          'country': country.text,
          'zip_code': zip.text
        };

        await CustomerApi().add(newCustomer).then((value) {
          if (value['data'] != null) {
            Contact()
                .insertContact(Contact().contactModel(value['data']))
                .then((value) {
              widget.onCustomerCreated();
              Navigator.pop(context);
              _formKey.currentState!.reset();
            });
          }
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('check_connectivity'),
      );
    }
  }
}