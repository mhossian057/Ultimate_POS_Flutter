import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../helpers/otherHelpers.dart';
import '../../../locale/MyLocalizations.dart';
import '../../../apis/sell.dart';

class AllSalesActionButtons extends StatelessWidget {
  final Map<String, dynamic> salesItem;
  final int index;
  final bool canDeleteSell;
  final Set<int> printingAllSalesItems;
  final Set<int> sharingAllSalesItems;
  final Function(int) onPrintingStateChanged;
  final Function(int) onSharingStateChanged;
  final Function(int) onDeleteItem;
  final ThemeData themeData;

  const AllSalesActionButtons({
    Key? key,
    required this.salesItem,
    required this.index,
    required this.canDeleteSell,
    required this.printingAllSalesItems,
    required this.sharingAllSalesItems,
    required this.onPrintingStateChanged,
    required this.onSharingStateChanged,
    required this.onDeleteItem,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canDeleteSell) _buildDeleteButton(context),
        if (salesItem['invoice_url'] != null) _buildPrintButton(context),
        if (salesItem['invoice_url'] != null) _buildShareButton(context),
        if (salesItem['mobile'] != null &&
            salesItem['status'].toString().toLowerCase() != 'paid')
          _buildCallButton(context),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: Icon(MdiIcons.deleteOutline, color: Colors.red),
      onPressed: () => _showDeleteDialog(context),
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    int salesId = salesItem['id'];
    return IconButton(
      icon: printingAllSalesItems.contains(salesId)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : Icon(MdiIcons.printerWireless, color: Colors.deepPurple),
      onPressed: printingAllSalesItems.contains(salesId)
          ? null
          : () => _handlePrint(context, salesId),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    int salesId = salesItem['id'];
    return IconButton(
      icon: sharingAllSalesItems.contains(salesId)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(themeData.colorScheme.primary),
              ),
            )
          : Icon(MdiIcons.shareVariant, color: themeData.colorScheme.primary),
      onPressed: sharingAllSalesItems.contains(salesId)
          ? null
          : () => _handleShare(context, salesId),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.call_outlined, color: Colors.green),
      onPressed: () async {
        await launch('tel:${salesItem['mobile']}');
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(MdiIcons.alert, color: Colors.red, size: MySize.size50),
          content: Text(
              AppLocalizations.of(context).translate('are_you_sure'),
              textAlign: TextAlign.center,
              style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true)),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: themeData.colorScheme.onPrimary,
                    foregroundColor: themeData.colorScheme.primary),
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('cancel'))),
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: themeData.colorScheme.onError),
                onPressed: () async {
                  Navigator.pop(context);
                  await SellApi().delete(salesItem['id']).then((value) {
                    if (value != null) {
                      onDeleteItem(index);
                      Fluttertoast.showToast(msg: '${value['msg']}');
                    }
                  });
                },
                child: Text(AppLocalizations.of(context).translate('ok')))
          ],
        );
      },
    );
  }

  void _handlePrint(BuildContext context, int salesId) async {
    onPrintingStateChanged(salesId);
    
    try {
      print('DEBUG PRINT: Starting print for salesId: $salesId');
      print('DEBUG PRINT: salesItem data: $salesItem');
      print('DEBUG PRINT: invoice_url: ${salesItem['invoice_url']}');
      
      _showLoadingDialog(context, 'Opening Invoice...');
      
      if (await Helper().checkConnectivity()) {
        print('DEBUG PRINT: Connectivity OK, using server invoice');
        // Use the server-generated invoice URL for printing
        await _printServerInvoice(salesItem['invoice_url']);
        print('DEBUG PRINT: Server invoice printed successfully');
      } else {
        print('DEBUG PRINT: No connectivity');
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('check_connectivity'));
      }
      
      Navigator.pop(context);
    } catch (e) {
      print('DEBUG PRINT: Error caught: $e');
      print('DEBUG PRINT: Error type: ${e.runtimeType}');
      print('DEBUG PRINT: Error stack trace: ${StackTrace.current}');
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Print Error: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG);
      _showErrorSnackbar(context);
    } finally {
      onPrintingStateChanged(salesId);
    }
  }

  void _handleShare(BuildContext context, int salesId) async {
    onSharingStateChanged(salesId);
    
    try {
      print('DEBUG SHARE: Starting share for salesId: $salesId');
      print('DEBUG SHARE: salesItem data: $salesItem');
      print('DEBUG SHARE: invoice_url: ${salesItem['invoice_url']}');
      print('DEBUG SHARE: invoice_no: ${salesItem['invoice_no']}');
      
      _showLoadingDialog(context, 'Preparing Invoice...');
      
      if (await Helper().checkConnectivity()) {
        print('DEBUG SHARE: Connectivity OK, using server invoice');
        // Use the server-generated invoice URL for sharing
        await _shareServerInvoice(salesItem['invoice_url'], salesItem['invoice_no']);
        print('DEBUG SHARE: Server invoice shared successfully');
      } else {
        print('DEBUG SHARE: No connectivity');
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('check_connectivity'));
      }
      
      Navigator.pop(context);
    } catch (e) {
      print('DEBUG SHARE: Error caught: $e');
      print('DEBUG SHARE: Error type: ${e.runtimeType}');
      print('DEBUG SHARE: Error stack trace: ${StackTrace.current}');
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Share Error: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG);
      _showErrorSnackbar(context);
    } finally {
      onSharingStateChanged(salesId);
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
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
                  child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)
            .translate('something_went_wrong')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _printServerInvoice(String invoiceUrl) async {
    if (invoiceUrl.isNotEmpty) {
      // For server invoices, open the URL for printing
      await launch(invoiceUrl);
    } else {
      throw Exception('Invoice URL is empty');
    }
  }

  Future<void> _shareServerInvoice(String invoiceUrl, String invoiceNo) async {
    if (invoiceUrl.isNotEmpty) {
      // Use Share library to share the invoice URL
      await Share.share(
        invoiceUrl,
        subject: 'Invoice: ${invoiceNo ?? 'Invoice'}',
      );
    } else {
      throw Exception('Invoice URL is empty');
    }
  }
}