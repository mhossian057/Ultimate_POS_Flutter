import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../helpers/otherHelpers.dart';
import '../../../locale/MyLocalizations.dart';

class PrintShareButtons extends StatelessWidget {
  final Map<String, dynamic> item;
  final Set<int> printingItems;
  final Set<int> sharingItems;
  final Function(int) onPrintingStateChanged;
  final Function(int) onSharingStateChanged;
  final ThemeData themeData;

  const PrintShareButtons({
    Key? key,
    required this.item,
    required this.printingItems,
    required this.sharingItems,
    required this.onPrintingStateChanged,
    required this.onSharingStateChanged,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPrintButton(context),
        _buildShareButton(context),
      ],
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    int itemId = item['id'];
    return IconButton(
      icon: printingItems.contains(itemId)
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
      onPressed: printingItems.contains(itemId)
          ? null
          : () async {
              onPrintingStateChanged(itemId);
              
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
                    item['id'],
                    item['tax_rate_id'],
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
                onPrintingStateChanged(itemId);
              }
            },
    );
  }

  Widget _buildShareButton(BuildContext context) {
    int itemId = item['id'];
    return IconButton(
      icon: sharingItems.contains(itemId)
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
      onPressed: sharingItems.contains(itemId)
          ? null
          : () async {
              onSharingStateChanged(itemId);
              
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
                    item['id'],
                    item['tax_rate_id'],
                    context,
                    item['invoice_no']);
                    
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
                onSharingStateChanged(itemId);
              }
            },
    );
  }
}