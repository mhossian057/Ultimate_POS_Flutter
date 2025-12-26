import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../locale/MyLocalizations.dart';
import 'customer_location_fields.dart';

class CustomerAddressFields extends StatelessWidget {
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController country;
  final TextEditingController zip;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  CustomerAddressFields({
    Key? key,
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
        _buildAddressSection(context),
        CustomerLocationFields(
          city: city,
          state: state,
          country: country,
          zip: zip,
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 64,
            child: Center(
              child: Icon(
                MdiIcons.homeCityOutline,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: addressLine1,
                    style: themeData.textTheme.titleSmall!.merge(
                      TextStyle(color: themeData.colorScheme.onBackground),
                    ),
                    decoration: _getInputDecoration(context, 'address_line_1'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  TextFormField(
                    controller: addressLine2,
                    style: themeData.textTheme.titleSmall!.merge(
                      TextStyle(color: themeData.colorScheme.onBackground),
                    ),
                    decoration: _getInputDecoration(context, 'address_line_2'),
                    textCapitalization: TextCapitalization.sentences,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String key) {
    return InputDecoration(
      hintStyle: themeData.textTheme.titleSmall!.merge(
        TextStyle(color: themeData.colorScheme.onBackground),
      ),
      hintText: AppLocalizations.of(context).translate(key),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: themeData.inputDecorationTheme.border!.borderSide.color,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: themeData.inputDecorationTheme.enabledBorder!.borderSide.color,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: themeData.inputDecorationTheme.focusedBorder!.borderSide.color,
        ),
      ),
    );
  }
}