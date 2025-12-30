import 'package:flutter/material.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../locale/MyLocalizations.dart';
import 'all_sales_action_buttons.dart';

class AllSalesItem extends StatelessWidget {
  final Map<String, dynamic> salesItem;
  final int index;
  final String symbol;
  final bool canDeleteSell;
  final Set<int> printingAllSalesItems;
  final Set<int> sharingAllSalesItems;
  final Function(int) onPrintingStateChanged;
  final Function(int) onSharingStateChanged;
  final Function(int) onDeleteItem;
  final ThemeData themeData;
  final CustomAppTheme customAppTheme;

  const AllSalesItem({
    Key? key,
    required this.salesItem,
    required this.index,
    required this.symbol,
    required this.canDeleteSell,
    required this.printingAllSalesItems,
    required this.sharingAllSalesItems,
    required this.onPrintingStateChanged,
    required this.onSharingStateChanged,
    required this.onDeleteItem,
    required this.themeData,
    required this.customAppTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double space = MySize.size16!;
    
    return Container(
      padding: EdgeInsets.all(space),
      margin: EdgeInsets.only(bottom: MySize.size12!),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(MySize.size12!)),
        color: customAppTheme.bgLayer1,
        border: Border.all(color: customAppTheme.bgLayer4, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: MySize.size8!),
                child: Text(
                  salesItem['date_time'],
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 500,
                    letterSpacing: 0.3,
                    color: themeData.colorScheme.onBackground.withAlpha(140),
                  ),
                ),
              ),
              _buildSalesInfo(context),
              SizedBox(height: MySize.size12!),
              if (index != null)
                Container(
                  padding: EdgeInsets.only(top: MySize.size8!),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: customAppTheme.bgLayer4.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: AllSalesActionButtons(
                    salesItem: salesItem,
                    index: index,
                    canDeleteSell: canDeleteSell,
                    printingAllSalesItems: printingAllSalesItems,
                    sharingAllSalesItems: sharingAllSalesItems,
                    onPrintingStateChanged: onPrintingStateChanged,
                    onSharingStateChanged: onSharingStateChanged,
                    onDeleteItem: onDeleteItem,
                    themeData: themeData,
                  ),
                ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.size12!,
                vertical: MySize.size6!,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(MySize.size12!),
                  bottomLeft: Radius.circular(MySize.size8!),
                ),
                color: (int.parse(salesItem['is_quotation'].toString()) == 0)
                    ? _checkStatusColor(salesItem['status'])
                    : Colors.amber.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                (int.parse(salesItem['is_quotation'].toString()) == 0) 
                    ? salesItem['status'].toUpperCase() 
                    : 'QUOTATION',
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodySmall,
                  fontSize: 11,
                  fontWeight: 700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSalesInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: MySize.size8!, right: MySize.size60!),
          child: Text(
            (int.parse(salesItem['is_quotation'].toString()) == 0)
                ? AppLocalizations.of(context).translate('invoice_no') +
                    " ${salesItem['invoice_no']}"
                : AppLocalizations.of(context).translate('ref_no') +
                    " ${salesItem['invoice_no']}",
            style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              fontWeight: 700,
              letterSpacing: -0.1,
              color: themeData.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: MySize.size6!),
          padding: EdgeInsets.symmetric(
            horizontal: MySize.size12!,
            vertical: MySize.size8!,
          ),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MySize.size8!),
            border: Border.all(
              color: themeData.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('invoice_amount'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  fontWeight: 500,
                  letterSpacing: 0,
                  color: themeData.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                "$symbol ${salesItem['invoice_amount']}",
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  fontWeight: 700,
                  letterSpacing: -0.1,
                  color: themeData.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (int.parse(salesItem['is_quotation'].toString()) == 0)
          Container(
            margin: EdgeInsets.only(bottom: MySize.size12!),
            padding: EdgeInsets.symmetric(
              horizontal: MySize.size12!,
              vertical: MySize.size8!,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(MySize.size8!),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate('paid_amount'),
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    fontWeight: 500,
                    letterSpacing: 0,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  "$symbol ${salesItem['paid_amount']}",
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.titleMedium,
                    fontWeight: 700,
                    letterSpacing: -0.1,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: MySize.size6!),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MySize.size80!,
                child: Text(
                  "${AppLocalizations.of(context).translate('customer_name')}: ",
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 500,
                    letterSpacing: 0.1,
                    color: themeData.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "${salesItem['contact_name']}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    fontWeight: 600,
                    letterSpacing: -0.1,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MySize.size80!,
              child: Text(
                AppLocalizations.of(context).translate('location_name') + ": ",
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodySmall,
                  fontWeight: 500,
                  letterSpacing: 0.1,
                  color: themeData.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "${salesItem['location_name']}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  fontWeight: 600,
                  letterSpacing: -0.1,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _checkStatusColor(String? status) {
    if (status != null) {
      switch (status.toLowerCase()) {
        case 'paid':
          return Colors.green.shade600;
        case 'due':
          return Colors.red.shade600;
        case 'partial':
          return Colors.orange.shade600;
        case 'overdue':
          return Colors.red.shade800;
        case 'final':
          return Colors.blue.shade600;
        case 'draft':
          return Colors.grey.shade600;
        default:
          return Colors.grey.shade500;
      }
    } else {
      return Colors.grey.shade400;
    }
  }
}