import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';

class CustomerNameFields extends StatelessWidget {
  final TextEditingController prefix;
  final TextEditingController firstName;
  final TextEditingController middleName;
  final TextEditingController lastName;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  CustomerNameFields({
    Key? key,
    required this.prefix,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 64,
          child: Center(
            child: Icon(
              MdiIcons.accountChildCircle,
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
                _buildPrefixAndFirstName(context),
                _buildMiddleAndLastName(context),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPrefixAndFirstName(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 50,
          child: TextFormField(
            controller: prefix,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(
              AppLocalizations.of(context).translate('prefix'),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
        Expanded(
          child: TextFormField(
            controller: firstName,
            validator: (value) {
              if (value!.length < 1) {
                return AppLocalizations.of(context)
                    .translate('please_enter_your_name');
              }
              return null;
            },
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(
              AppLocalizations.of(context).translate('first_name'),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        )
      ],
    );
  }

  Widget _buildMiddleAndLastName(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: middleName,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(
              AppLocalizations.of(context).translate('middle_name'),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Container(
          width: MySize.screenWidth! * 0.35,
          child: TextFormField(
            controller: lastName,
            style: themeData.textTheme.titleSmall!.merge(
              TextStyle(color: themeData.colorScheme.onBackground),
            ),
            decoration: _getInputDecoration(
              AppLocalizations.of(context).translate('last_name'),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        )
      ],
    );
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintStyle: themeData.textTheme.titleSmall!.merge(
        TextStyle(color: themeData.colorScheme.onBackground),
      ),
      hintText: hintText,
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