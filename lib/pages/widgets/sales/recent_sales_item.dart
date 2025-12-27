import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../locale/MyLocalizations.dart';
import 'sales_action_buttons.dart';

class RecentSalesItem extends StatelessWidget {
  final Map<String, dynamic> sellItem;
  final int index;
  final String symbol;
  final bool canEditSell;
  final bool canDeleteSell;
  final Set<int> printingItems;
  final Set<int> sharingItems;
  final Function(int) onPrintingStateChanged;
  final Function(int) onSharingStateChanged;
  final Function(BuildContext, Map<String, dynamic>) onEdit;
  final Function(BuildContext, Map<String, dynamic>) onDelete;
  final Function(BuildContext, Map<String, dynamic>) onPayment;
  final ThemeData themeData;
  final CustomAppTheme customAppTheme;

  const RecentSalesItem({
    Key? key,
    required this.sellItem,
    required this.index,
    required this.symbol,
    required this.canEditSell,
    required this.canDeleteSell,
    required this.printingItems,
    required this.sharingItems,
    required this.onPrintingStateChanged,
    required this.onSharingStateChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onPayment,
    required this.themeData,
    required this.customAppTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double space = MySize.size12!;
    
    return Container(
      padding: EdgeInsets.only(top: space, right: space, left: space),
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
              Text(
                sellItem['transaction_date'],
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                    fontWeight: 600,
                    letterSpacing: -0.2,
                    color: themeData.colorScheme.onBackground.withAlpha(160)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (sellItem['is_quotation'] == 0)
                            ? AppLocalizations.of(context)
                                    .translate('invoice_no') +
                                " ${sellItem['invoice_no']}"
                            : AppLocalizations.of(context).translate('ref_no') +
                                " ${sellItem['invoice_no']}",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.titleMedium,
                            fontWeight: 700,
                            letterSpacing: -0.2),
                      ),
                      Text(
                        AppLocalizations.of(context)
                                .translate('invoice_amount') +
                            " $symbol ${sellItem['invoice_amount']}",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            fontWeight: 600,
                            letterSpacing: 0),
                      ),
                      if (sellItem['is_quotation'] == 0)
                        Text(
                          AppLocalizations.of(context)
                                  .translate('paid_amount') +
                              " $symbol ${sellItem['paid_amount']}",
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyMedium,
                              fontWeight: 600,
                              letterSpacing: 0),
                        ),
                      Text(
                        AppLocalizations.of(context)
                                .translate('customer_name') +
                            ": ${sellItem['customer_name']}",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            fontWeight: 600,
                            letterSpacing: 0),
                      ),
                      Text(
                        AppLocalizations.of(context)
                                .translate('location_name') +
                            ": ${sellItem['location_name']}",
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            fontWeight: 600,
                            letterSpacing: 0),
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: index != null,
                child: SalesActionButtons(
                  sellItem: sellItem,
                  index: index,
                  canEditSell: canEditSell,
                  canDeleteSell: canDeleteSell,
                  printingItems: printingItems,
                  sharingItems: sharingItems,
                  onPrintingStateChanged: onPrintingStateChanged,
                  onSharingStateChanged: onSharingStateChanged,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onPayment: onPayment,
                  themeData: themeData,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(MySize.size5!),
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(MySize.size4!)),
                        color: (sellItem['is_quotation'] == 0)
                            ? _checkStatusColor(sellItem['status'])
                            : Colors.yellowAccent),
                    child: Text(
                      (sellItem['is_quotation'] == 0) 
                          ? sellItem['status'].toUpperCase() 
                          : 'QUOTATION',
                      style: AppTheme.getTextStyle(themeData.textTheme.bodySmall,
                          fontSize: 14, fontWeight: 700, letterSpacing: 0.2),
                    ),
                  ),
                  Visibility(
                    visible: index != null,
                    child: Padding(
                      padding: EdgeInsets.all(MySize.size8!),
                      child: (sellItem['is_synced'] == 0)
                          ? Icon(
                              MdiIcons.syncAlert,
                              color: Colors.black,
                            )
                          : Container(),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
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