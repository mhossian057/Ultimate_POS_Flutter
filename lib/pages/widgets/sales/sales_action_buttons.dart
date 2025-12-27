import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/otherHelpers.dart';
import '../../../locale/MyLocalizations.dart';

class SalesActionButtons extends StatelessWidget {
  final Map<String, dynamic> sellItem;
  final int index;
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

  const SalesActionButtons({
    Key? key,
    required this.sellItem,
    required this.index,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canEditSell)
          IconButton(
            icon: Icon(
              MdiIcons.fileDocumentEditOutline,
              color: themeData.colorScheme.onBackground,
            ),
            onPressed: () => onEdit(context, sellItem),
          ),
        if (canDeleteSell)
          IconButton(
            icon: Icon(
              MdiIcons.deleteOutline,
              color: Colors.red,
            ),
            onPressed: () => onDelete(context, sellItem),
          ),
        _buildPrintButton(context),
        _buildShareButton(context),
        if (sellItem['pending_amount'] > 0 && canEditSell)
          IconButton(
            icon: Icon(
              MdiIcons.creditCardOutline,
              color: Colors.purpleAccent,
            ),
            onPressed: () => onPayment(context, sellItem),
          ),
        if (sellItem['pending_amount'] > 0 && 
            canEditSell && 
            sellItem['mobile'] != null)
          IconButton(
            icon: Icon(
              Icons.call_outlined,
              color: Colors.green,
            ),
            onPressed: () async {
              await launch('tel:${sellItem['mobile']}');
            },
          ),
      ],
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    int sellId = sellItem['id'];
    return IconButton(
      icon: printingItems.contains(sellId)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : Icon(
              MdiIcons.printerWireless,
              color: Colors.deepPurple,
            ),
      onPressed: printingItems.contains(sellId)
          ? null
          : () async {
              onPrintingStateChanged(sellId);
              
              try {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text('Generating Invoice...')),
                        ],
                      ),
                    );
                  },
                );
                
                await Helper().printDocument(
                    sellItem['id'],
                    sellItem['tax_rate_id'],
                    context);
                    
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .translate('something_went_wrong')),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                onPrintingStateChanged(sellId);
              }
            },
    );
  }

  Widget _buildShareButton(BuildContext context) {
    int sellId = sellItem['id'];
    return IconButton(
      icon: sharingItems.contains(sellId)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(themeData.colorScheme.primary),
              ),
            )
          : Icon(
              MdiIcons.shareVariant,
              color: themeData.colorScheme.primary,
            ),
      onPressed: sharingItems.contains(sellId)
          ? null
          : () async {
              onSharingStateChanged(sellId);
              
              try {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text('Preparing Invoice...')),
                        ],
                      ),
                    );
                  },
                );
                
                await Helper().savePdf(
                    sellItem['id'],
                    sellItem['tax_rate_id'],
                    context,
                    sellItem['invoice_no']);
                    
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .translate('something_went_wrong')),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                onSharingStateChanged(sellId);
              }
            },
    );
  }
}