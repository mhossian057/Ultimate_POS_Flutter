import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../locale/MyLocalizations.dart';

class CustomerPhoneField extends StatelessWidget {
  final TextEditingController mobile;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  CustomerPhoneField({
    Key? key,
    required this.mobile,
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
                MdiIcons.phoneOutline,
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: TextFormField(
                controller: mobile,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.length < 1) {
                    return AppLocalizations.of(context)
                        .translate('please_enter_your_number');
                  }
                  return null;
                },
                style: themeData.textTheme.titleSmall!.merge(
                  TextStyle(color: themeData.colorScheme.onBackground),
                ),
                decoration: _getInputDecoration(context),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    return InputDecoration(
      hintStyle: themeData.textTheme.titleSmall!.merge(
        TextStyle(color: themeData.colorScheme.onBackground),
      ),
      hintText: AppLocalizations.of(context).translate('phone'),
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