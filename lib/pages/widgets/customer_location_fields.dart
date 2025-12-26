import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';

class CustomerLocationFields extends StatelessWidget {
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController country;
  final TextEditingController zip;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  CustomerLocationFields({
    Key? key,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  _buildCityStateRow(context),
                  _buildCountryZipRow(context),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCityStateRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: city,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(context, 'city'),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: state,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(context, 'state'),
            textCapitalization: TextCapitalization.sentences,
          ),
        )
      ],
    );
  }

  Widget _buildCountryZipRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: country,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(context, 'country'),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: zip,
            keyboardType: TextInputType.number,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(context, 'zip_code'),
            textCapitalization: TextCapitalization.sentences,
          ),
        )
      ],
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