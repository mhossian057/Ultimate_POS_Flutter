import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';
import '../../models/sell.dart';

class ProductVariationsDialog extends StatelessWidget {
  final List variations;
  final String symbol;
  final String productName;
  final bool canAddSell;
  final bool canMakeSell;
  final Map? argument;

  const ProductVariationsDialog({
    Key? key,
    required this.variations,
    required this.symbol,
    required this.productName,
    required this.canAddSell,
    required this.canMakeSell,
    this.argument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, themeData),
            Flexible(
              child: _buildVariationsList(context, themeData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData themeData) {
    return Container(
      padding: EdgeInsets.all(MySize.size20!),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              productName,
              style: AppTheme.getTextStyle(
                themeData.textTheme.titleLarge,
                color: themeData.colorScheme.onPrimary,
                fontWeight: 600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: themeData.colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsList(BuildContext context, ThemeData themeData) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(MySize.size16!),
      itemCount: variations.length,
      itemBuilder: (context, index) {
        final variation = variations[index];
        final stockAvailable = variation['stock_available'] ?? 0;
        final isInStock = stockAvailable > 0;
        
        return Card(
          margin: EdgeInsets.only(bottom: MySize.size12!),
          child: ListTile(
            contentPadding: EdgeInsets.all(MySize.size16!),
            title: Text(
              (variation['variation_name'] != null && variation['variation_name'].toString().isNotEmpty) 
                ? variation['variation_name'] 
                : 'Default',
              style: AppTheme.getTextStyle(
                themeData.textTheme.titleMedium,
                fontWeight: 600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MySize.size8!),
                Text(
                  '${symbol}${_formatPrice(variation['sell_price_inc_tax'])}',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.titleMedium,
                    color: themeData.colorScheme.primary,
                    fontWeight: 600,
                  ),
                ),
                if (variation['enable_stock'] == 1) ...[
                  SizedBox(height: MySize.size4!),
                  Text(
                    '${AppLocalizations.of(context).translate('stock')}: ${stockAvailable.toString()}',
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.bodySmall,
                      color: isInStock ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            trailing: ElevatedButton(
              onPressed: isInStock || variation['enable_stock'] == 0
                  ? () => _addToCart(context, variation, index)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.colorScheme.primary,
                foregroundColor: themeData.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('add_to_cart'),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    try {
      return double.parse(price.toString()).toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  void _addToCart(BuildContext context, Map variation, int index) async {
    if (!canAddSell || !canMakeSell) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('no_sells_permission'),
      );
      return;
    }

    if (variation['enable_stock'] == 1 && variation['stock_available'] <= 0) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('out_of_stock'),
      );
      return;
    }

    try {
      // Add to cart using the processed variation data
      await Sell().addToCart(
        variation,
        argument != null ? argument!['sellId'] : null,
      );

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('added_to_cart'),
      );

      // Close dialog
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error adding to cart: $e',
      );
    }
  }
}