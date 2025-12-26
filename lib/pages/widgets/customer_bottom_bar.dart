import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/style.dart' as style;
import '../../locale/MyLocalizations.dart';
import '../elements.dart';

class CustomerBottomBar extends StatelessWidget {
  final Map<String, dynamic> selectedCustomer;
  final Map<String, dynamic>? argument;
  final VoidCallback onAddQuotation;

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  CustomerBottomBar({
    Key? key,
    required this.selectedCustomer,
    required this.argument,
    required this.onAddQuotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedCustomer['id'] == 0) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: (argument!['is_quotation'] == null)
          ? MainAxisAlignment.spaceAround
          : MainAxisAlignment.center,
      children: [
        if (argument!['is_quotation'] == null) _buildQuotationButton(context),
        _buildCheckoutButton(context),
      ],
    );
  }

  Widget _buildQuotationButton(BuildContext context) {
    return TextButton(
      onPressed: onAddQuotation,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: style.StyleColors().mainColor(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.surface,
          ),
          Text(
            AppLocalizations.of(context).translate('add_quotation'),
            style: AppTheme.getTextStyle(
              Theme.of(context).textTheme.bodyLarge,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return cartBottomBar(
      '/checkout',
      AppLocalizations.of(context).translate('pay_&_checkout'),
      context,
      _buildCheckoutArguments(),
    );
  }

  Map<String, dynamic> _buildCheckoutArguments() {
    return {
      'locationId': argument!['locationId'],
      'taxId': argument!['taxId'],
      'discountType': argument!['discountType'],
      'discountAmount': argument!['discountAmount'],
      'invoiceAmount': argument!['invoiceAmount'],
      'customerId': selectedCustomer['id'],
      'sellId': argument!['sellId'],
    };
  }
}