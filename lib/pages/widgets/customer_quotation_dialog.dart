import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/otherHelpers.dart';
import '../../locale/MyLocalizations.dart';
import '../../models/sell.dart';
import '../../models/sellDatabase.dart';

class CustomerQuotationDialog extends StatelessWidget {
  final Map<String, dynamic> sell;
  final Map<String, dynamic>? argument;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  CustomerQuotationDialog({
    Key? key,
    required this.sell,
    required this.argument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: customAppTheme.bgLayer1,
      title: Text(
        AppLocalizations.of(context).translate('quotation'),
        style: AppTheme.getTextStyle(
          themeData.textTheme.headlineSmall,
          color: themeData.colorScheme.onSurface,
          fontWeight: 700,
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeData.colorScheme.primary,
          ),
          onPressed: () => _handleSave(context, false),
          child: Text(AppLocalizations.of(context).translate('save')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeData.colorScheme.primary,
          ),
          onPressed: () => _handleSave(context, true),
          child: Text(AppLocalizations.of(context).translate('save_n_print')),
        )
      ],
    );
  }

  Future<void> _handleSave(BuildContext context, bool shouldPrint) async {
    if (argument!['sellId'] != null) {
      // Handle update sell logic
    } else {
      await SellDatabase().storeSell(sell).then((value) async {
        SellDatabase().updateSellLine({'sell_id': value, 'is_completed': 1});
        if (await Helper().checkConnectivity()) {
          await Sell().createApiSell(sellId: value);
        }

        if (shouldPrint) {
          Helper().printDocument(value, argument!['taxId'], context).then((value) {
            _navigateToProducts(context);
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('quotation_added'),
            );
          });
        } else {
          _navigateToProducts(context);
        }
      });
    }
  }

  void _navigateToProducts(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/products',
      ModalRoute.withName('/home'),
    );
  }
}