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
    double space = MySize.size12!;
    
    return Container(
      padding: EdgeInsets.only(left: space, right: space, top: space),
      margin: EdgeInsets.only(top: MySize.size0!, bottom: space),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
        color: customAppTheme.bgLayer1,
        border: Border.all(color: customAppTheme.bgLayer4, width: 1.2),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(salesItem['date_time'],
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                      fontWeight: 600,
                      letterSpacing: -0.2,
                      color: themeData.colorScheme.onBackground.withAlpha(160))),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _buildSalesInfo(context)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Visibility(
                    visible: index != null,
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: MySize.size12!,
                    right: MySize.size12!,
                    top: MySize.size8!,
                    bottom: MySize.size8!),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(MySize.size4!)),
                    color: (int.parse(salesItem['is_quotation'].toString()) == 0)
                        ? _checkStatusColor(salesItem['status'])
                        : Colors.yellowAccent),
                child: Text(
                  (int.parse(salesItem['is_quotation'].toString()) == 0) 
                      ? salesItem['status'].toUpperCase() 
                      : 'QUOTATION',
                  style: AppTheme.getTextStyle(themeData.textTheme.bodySmall,
                      fontSize: 12, fontWeight: 700, letterSpacing: 0.2),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSalesInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          (int.parse(salesItem['is_quotation'].toString()) == 0)
              ? AppLocalizations.of(context).translate('invoice_no') +
                  " ${salesItem['invoice_no']}"
              : AppLocalizations.of(context).translate('ref_no') +
                  " ${salesItem['invoice_no']}",
          style: AppTheme.getTextStyle(
              themeData.textTheme.titleMedium,
              fontWeight: 700,
              letterSpacing: -0.2),
        ),
        Text(
          AppLocalizations.of(context).translate('invoice_amount') +
              " $symbol ${salesItem['invoice_amount']}",
          style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              fontWeight: 600,
              letterSpacing: 0),
        ),
        if (int.parse(salesItem['is_quotation'].toString()) == 0)
          Text(
            AppLocalizations.of(context).translate('paid_amount') +
                " $symbol ${salesItem['paid_amount']}",
            style: AppTheme.getTextStyle(
                themeData.textTheme.bodyMedium,
                fontWeight: 600,
                letterSpacing: 0),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context).translate('customer_name')}: ",
              style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  fontWeight: 600,
                  letterSpacing: 0),
            ),
            SizedBox(
              width: MySize.screenWidth! * 0.6,
              child: Text(
                "${salesItem['contact_name']}",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    fontWeight: 600,
                    letterSpacing: 0),
              ),
            ),
          ],
        ),
        Text(
          AppLocalizations.of(context).translate('location_name') +
              ": ${salesItem['location_name']}",
          maxLines: 3,
          style: AppTheme.getTextStyle(
              themeData.textTheme.bodyMedium,
              fontWeight: 600,
              letterSpacing: 0),
        ),
      ],
    );
  }

  Color _checkStatusColor(String? status) {
    if (status != null) {
      if (status.toLowerCase() == 'paid')
        return Colors.green;
      else if (status.toLowerCase() == 'due')
        return Colors.red;
      else
        return Colors.orange;
    } else {
      return Colors.black12;
    }
  }
}