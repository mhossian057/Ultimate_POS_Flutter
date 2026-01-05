import 'dart:io';
import 'dart:typed_data';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../locale/MyLocalizations.dart';
import '../models/invoice.dart';
import '../models/system.dart';
import '../models/sellDatabase.dart';
import '../models/paymentDatabase.dart';
import '../models/contact_model.dart';
import 'AppTheme.dart';
import 'SizeConfig.dart';

class Helper {
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  Widget loadingIndicator(context) {
    return Center(
      child: Card(
        elevation: MySize.size10,
        child: Container(
          padding: EdgeInsets.all(MySize.size28!),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MySize.size8!),
          ),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  //format currency
  String formatCurrency(amount) {
    double convertAmount = double.parse(amount.toString());

    var amt = NumberFormat.currency(
            symbol: '', decimalDigits: Config.currencyPrecision)
        .format(convertAmount);
    return amt;
  }

  double validateInput(String val) {
    try {
      double value = double.parse(val.toString());
      return value;
    } catch (e) {
      return 0.00;
    }
  }

  //format quantity
  String formatQuantity(amount) {
    double quantity = double.parse(amount.toString());
    var amt = NumberFormat.currency(
            symbol: '', decimalDigits: Config.quantityPrecision)
        .format(quantity);
    return amt;
  }

  //argument model
  Map argument(
      {int? sellId,
      int? locId,
      int? taxId,
      String? discountType,
      double? discountAmount,
      double? invoiceAmount,
      int? customerId,
      int? isQuotation}) {
    Map args = {
      'sellId': sellId,
      'locationId': locId,
      'taxId': taxId,
      'discountType': discountType,
      'discountAmount': discountAmount,
      'invoiceAmount': invoiceAmount,
      'customerId': customerId,
      'is_quotation': isQuotation
    };
    return args;
  }

  //check internet connectivity
  Future<bool> checkConnectivity() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.mobile) ||
           connectivityResults.contains(ConnectivityResult.wifi);
  }

  //get location name by location_id
  Future<String?> getLocationNameById(var id) async {
    String? locationName;
    var response = await System().get('location');
    response.forEach((element) {
      if (element['id'] == int.parse(id.toString())) {
        locationName = element['name'];
      }
    });
    return locationName;
  }

  //calculate inline tax and discount amount
  calculateTaxAndDiscount(
      {discountAmount, discountType, taxId, unitPrice}) async {
    double disAmt = 0.0, tax = 0.00, taxAmt = 0.00;
    await System().get('tax').then((value) {
      value.forEach((element) {
        if (element['id'] == taxId) {
          tax = double.parse(element['amount'].toString()) * 1.0;
        }
      });
    });

    if (discountType == 'fixed') {
      disAmt = discountAmount;
      taxAmt = ((unitPrice - discountAmount) * tax / 100);
    } else {
      disAmt = (unitPrice * discountAmount / 100);
      taxAmt = ((unitPrice - (unitPrice * discountAmount / 100)) * tax / 100);
    }
    return {'discountAmount': disAmt, 'taxAmount': taxAmt};
  }

  //calculate price excluding tax (for subtotal display)
  calculateTotalExcludingTax({unitPrice, discountType, discountAmount}) async {
    double amount = 0.0;
    unitPrice = double.parse(unitPrice.toString());
    discountAmount = double.parse(discountAmount.toString());
    
    //calculate amount after discount but before tax
    if (discountType == 'fixed') {
      amount = unitPrice - discountAmount;
    } else {
      amount = unitPrice - (unitPrice * discountAmount / 100);
    }
    return amount.toStringAsFixed(2);
  }

  //calculate price including tax
  calculateTotal({unitPrice, discountType, discountAmount, taxId}) async {
    double tax = 0.00;
    double subTotal = 0.00;
    double amount = 0.0;
    unitPrice = double.parse(unitPrice.toString());
    discountAmount = double.parse(discountAmount.toString());
    //set tax
    await System().get('tax').then((value) {
      value.forEach((element) {
        if (element['id'] == taxId) {
          tax = double.parse(element['amount'].toString()) * 1.0;
        }
      });
    });
    //calculate subTotal according to discount type
    if (discountType == 'fixed') {
      amount = unitPrice - discountAmount;
    } else {
      amount = unitPrice - (unitPrice * discountAmount / 100);
    }
    //calculate subtotal
    subTotal = (amount + (amount * tax / 100));
    return subTotal.toStringAsFixed(2);
  }

  Future<String> barcodeScan() async {
    var result = await BarcodeScanner.scan();
    return result.rawContent.trimRight();
  }

  //function for formatting invoice
  Future<void> printDocument(sellId, taxId, context, {invoice}) async {
    // Always use local invoice generation to ensure tax-excluded pricing consistency
    // regardless of whether we have a server invoice or not
    String _invoice = await InvoiceFormatter().generateInvoice(sellId, taxId, context);
    Printing.layoutPdf(onLayout: (pageFormat) async {
      final doc = pw.Document();
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
                format: format,
                html: _invoice,
              ));

      return doc.save();
    });
  }

  // //request permissions
  requestAppPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      // Permission.phone
    ].request();
    return statuses;
  }

  //job scheduler
  jobScheduler() {
    if (Config().syncCallLog) {
      final cron = Cron();
      cron.schedule(Schedule.parse('*/${Config.callLogSyncDuration} * * * *'),
          () async {
        syncCallLogs();
      });
    }
  }

  //post call_logs in api
  syncCallLogs() async {
    if (await Permission.phone.status == PermissionStatus.granted) {
      if (Config().syncCallLog && await Helper().checkConnectivity()) {
        // ignore: unused_local_variable
        List recentLogs = [];
        //get last sync time
        var lastSync = await System().callLogLastSyncDateTime();
        //difference between time now and last sync
        int getLogBefore = (lastSync != null)
            ? DateTime.now().difference(DateTime.parse(lastSync)).inMinutes
            : 1440;
        //set 'from' duration for call_log query
        // ignore: unused_local_variable
        int from = DateTime.now()
            .subtract(
                Duration(minutes: (getLogBefore > 1440) ? 1440 : getLogBefore))
            .millisecondsSinceEpoch;
        try {
          // //fetch call_log
          // await CallLog.query(dateFrom: from).then((value) async {
          //   if (value.isNotEmpty) {
          //     value.forEach((element) {
          //       recentLogs.add(CallLogModel().createLog(element));
          //     });
          //     //     //save call_log in api
          //     await FollowUpApi()
          //         .syncCallLog({'call_logs': recentLogs}).then((value) async {
          //       if (value == true) {
          //         System().callLogLastSyncDateTime(true);
          //       }
          //     });
          //   }
          // });
        } catch (e) {}
      }
    }
  }

  //share invoice
  savePdf(sellId, taxId, context, invoiceNo, {invoice}) async {
    try {
      // Always use local PDF generation to ensure tax-excluded pricing consistency
      // regardless of whether we have a server invoice or not
      Uint8List pdfBytes = await _createBasicInvoicePdf(sellId, taxId, context, invoiceNo);
      
      // Save to temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${invoiceNo ?? 'invoice'}.pdf');
      await file.writeAsBytes(pdfBytes);
      
      // Share the PDF file
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice: ${invoiceNo ?? 'invoice'}');
    } catch (e) {
      print('Error sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share invoice. Please try again.')),
      );
    }
  }

  // Create a complete invoice PDF that matches the print layout exactly
  Future<Uint8List> _createBasicInvoicePdf(sellId, taxId, context, invoiceNo) async {
    final doc = pw.Document();
    
    // Get complete business and invoice data
    final businessDetails = await getFormattedBusinessDetails();
    
    // Pre-load logo image if available
    pw.ImageProvider? logoImage;
    if (businessDetails['logo'] != null && businessDetails['logo'].isNotEmpty) {
      logoImage = await _loadLogoImage(businessDetails['logo']);
    }
    var sellDetails;
    var sellLines = [];
    var paymentLines = [];
    var customerDetails;
    var locationDetails = {};
    
    if (sellId != null) {
      try {
        // Get sell details
        var sellResult = await SellDatabase().getSellBySellId(sellId);
        sellDetails = sellResult.isNotEmpty ? sellResult[0] : null;
        
        if (sellDetails != null) {
          // Get customer details
          customerDetails = await Contact().getCustomerDetailById(sellDetails['contact_id']);
          
          // Get location details
          List locations = await System().get('location');
          locations.forEach((element) {
            if (element['id'] == sellDetails['location_id']) {
              locationDetails = element;
            }
          });
          
          // Get sell lines and payments - use same method as print function
          sellLines = await SellDatabase().get(sellId: sellId);
          paymentLines = await PaymentDatabase().get(sellId, allColumns: true);
        }
      } catch (e) {
        print('Error getting sell details: $e');
      }
    }
    
    // Calculate totals
    double subTotal = 0.0;
    double totalPaidAmount = 0.0;
    
    for (var line in sellLines) {
      double qty = (line['quantity'] ?? 0).toDouble();
      double unitPrice = (line['unit_price'] ?? 0).toDouble();
      double discountAmount = (line['discount_amount'] ?? 0).toDouble();
      String discountType = line['discount_type'] ?? 'fixed';
      
      // Calculate price excluding tax (after discount but before tax)
      double priceExcludingTax;
      if (discountType == 'fixed') {
        priceExcludingTax = unitPrice - discountAmount;
      } else {
        priceExcludingTax = unitPrice - (unitPrice * discountAmount / 100);
      }
      
      subTotal += qty * priceExcludingTax;
    }
    
    for (var payment in paymentLines) {
      if (payment['is_return'] == 0) {
        totalPaidAmount += (payment['amount'] ?? 0).toDouble();
      } else {
        totalPaidAmount -= (payment['amount'] ?? 0).toDouble();
      }
    }
    
    double invoiceTotal = sellDetails != null ? (sellDetails['invoice_amount'] ?? 0).toDouble() : subTotal;
    double dueAmount = invoiceTotal - totalPaidAmount;
    
    // Check show_total_before_vat setting
    bool showTotalBeforeVat = locationDetails['invoice_layout']?['common_settings']?['show_total_before_vat'] == "1" ||
                              locationDetails['invoice_layout']?['common_settings']?['show_total_before_vat'] == true;
    
    // Create business address
    String businessAddress = '';
    if (locationDetails.isNotEmpty) {
      List addressParts = [
        locationDetails['landmark'],
        locationDetails['city'],
        locationDetails['state'], 
        locationDetails['zip_code'],
        locationDetails['country'],
        locationDetails['mobile']
      ];
      businessAddress = addressParts.where((part) => part != null && part.toString().isNotEmpty).join(', ');
    }
    
    doc.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business Header - centered like the print version
              pw.Center(
                child: pw.Column(
                  children: [
                    // Business Logo - actual image if loaded, fallback to business name
                    if (logoImage != null)
                      pw.Container(
                        height: 60,
                        child: pw.Image(logoImage),
                      )
                    else if (businessDetails['logo'] != null && businessDetails['logo'].isNotEmpty)
                      pw.Container(
                        height: 40,
                        padding: pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            businessDetails['name'] ?? 'LOGO',
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    
                    // Business Name - large and bold like print version
                    pw.Text(
                      businessDetails['name'] ?? 'Business Name',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    
                    pw.SizedBox(height: 5),
                    
                    // Business Address
                    if (businessAddress.isNotEmpty)
                      pw.Text(
                        businessAddress,
                        style: pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.center,
                      ),
                    
                    pw.SizedBox(height: 3),
                    
                    // Tax Information
                    if (businessDetails['taxLabel'].isNotEmpty || businessDetails['taxNumber'].isNotEmpty)
                      pw.Text(
                        '${businessDetails['taxLabel']}${businessDetails['taxNumber']}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              
              // Invoice Details - left aligned like print version
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice No: ${invoiceNo ?? 'N/A'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${sellDetails?['transaction_date'] ?? 'N/A'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // Customer Information
              if (customerDetails != null) ...[
                pw.Text('Customer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text(customerDetails['name'] ?? 'Walk-in Customer', style: pw.TextStyle(fontSize: 14)),
                if (customerDetails['mobile'] != null)
                  pw.Text(customerDetails['mobile'], style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 15),
              ],
              
              pw.Divider(),
              pw.SizedBox(height: 5),
              
              // Items Table - clean format without borders
              pw.Column(
                children: [
                  // Table Header
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
                        pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.right)),
                        pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 4),
                  
                  // Table Rows
                  ...sellLines.map((line) {
                    double qty = (line['quantity'] ?? 0).toDouble();
                    double unitPrice = (line['unit_price'] ?? 0).toDouble();
                    double discountAmount = (line['discount_amount'] ?? 0).toDouble();
                    String discountType = line['discount_type'] ?? 'fixed';
                    
                    // Calculate price excluding tax (after discount but before tax)
                    double priceExcludingTax;
                    if (discountType == 'fixed') {
                      priceExcludingTax = unitPrice - discountAmount;
                    } else {
                      priceExcludingTax = unitPrice - (unitPrice * discountAmount / 100);
                    }
                    
                    double totalExcludingTax = qty * priceExcludingTax;
                    String productName = line['name'] ?? line['display_name'] ?? 'Product';
                    
                    return pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(productName, style: pw.TextStyle(fontSize: 11))),
                          pw.Expanded(flex: 1, child: pw.Text(formatQuantity(qty), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center)),
                          pw.Expanded(flex: 2, child: pw.Text('${businessDetails['symbol']} ${formatCurrency(priceExcludingTax)}', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.right)),
                          pw.Expanded(flex: 2, child: pw.Text('${businessDetails['symbol']} ${formatCurrency(totalExcludingTax)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // Totals Section - right aligned like print version
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              showTotalBeforeVat ? 'Total before VAT:' : 'Sub total:', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                            ),
                            pw.Text('${businessDetails['symbol']} ${formatCurrency(subTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        
                        pw.SizedBox(height: 8),
                        
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                            pw.Text('${businessDetails['symbol']} ${formatCurrency(invoiceTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        
                        pw.Divider(),
                        
                        // Payment Details
                        ...paymentLines.map((payment) => pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${payment['method']} ${payment['is_return'] == 1 ? '(-)' : '(+)'}'),
                            pw.Text('${businessDetails['symbol']} ${formatCurrency(payment['amount'])}'),
                          ],
                        )).toList(),
                        
                        pw.SizedBox(height: 5),
                        
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Paid:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('${businessDetails['symbol']} ${formatCurrency(totalPaidAmount)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        
                        if (dueAmount > 0) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Amount Due:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                              pw.Text('${businessDetails['symbol']} ${formatCurrency(dueAmount)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              
              // Footer - centered like print version
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return doc.save();
  }

  // Load logo image from various sources (URL, file path, etc.)
  Future<pw.ImageProvider?> _loadLogoImage(String logoPath) async {
    try {
      if (logoPath.startsWith('http://') || logoPath.startsWith('https://')) {
        // Load from URL
        final response = await http.get(Uri.parse(logoPath));
        if (response.statusCode == 200) {
          return pw.MemoryImage(response.bodyBytes);
        }
      } else if (logoPath.startsWith('assets/')) {
        // Load from assets - Note: This requires special handling in Flutter
        // For now, return null and fallback to business name
        print('Asset logo loading not yet implemented: $logoPath');
        return null;
      } else {
        // Try to load as local file
        final file = File(logoPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return pw.MemoryImage(bytes);
        }
      }
    } catch (e) {
      print('Error loading logo from $logoPath: $e');
    }
    
    return null; // Return null if loading fails
  }

  // Generate PDF directly using pdf package without HTML conversion
  Future<Uint8List> _generateInvoicePdf(sellId, taxId, context, invoiceNo, {invoice}) async {
    final doc = pw.Document();
    
    // Get business details
    final businessDetails = await getFormattedBusinessDetails();
    
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        businessDetails['name'] ?? 'Business Name',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('${businessDetails['taxLabel']}${businessDetails['taxNumber']}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('No: ${invoiceNo ?? 'N/A'}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Invoice content
              pw.Center(
                child: pw.Text(
                  'Invoice details will be generated here',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return doc.save();
  }

  //fetch formatted business details
  Future<Map<String, dynamic>> getFormattedBusinessDetails() async {
    List business = await System().get('business');
    String? symbol = business[0]['currency']['symbol'],
        name = business[0]['name'],
        logo = business[0]['logo'],
        taxLabel = business[0]['tax_label_1'],
        taxNumber = business[0]['tax_number_1'];
    int? currencyPrecision = int.tryParse(business[0]['currency_precision']?.toString() ?? ''),
        quantityPrecision = int.tryParse(business[0]['quantity_precision']?.toString() ?? '');
    
    // Get common settings
    Map<String, dynamic> commonSettings = {};
    if (business[0]['common_settings'] != null) {
      commonSettings = business[0]['common_settings'];
    }
    
    return {
      'symbol': symbol ?? '',
      'name': name ?? '',
      'logo': logo ?? Config().defaultBusinessImage,
      'currencyPrecision': currencyPrecision ?? Config.currencyPrecision,
      'quantityPrecision': quantityPrecision ?? Config.quantityPrecision,
      'taxLabel': (taxLabel != null) ? '$taxLabel : ' : '',
      'taxNumber': (taxNumber != null) ? '$taxNumber' : '',
      'commonSettings': commonSettings
    };
  }

  //Fetch permission from database
  Future<bool> getPermission(String permissionFor) async {
    bool permission = false;
    await System().getPermission().then((value) {
      if (value[0] == 'all' || value.contains("$permissionFor")) {
        permission = true;
      }
    });
    return permission;
  }

  //call widget
  Widget callDropdown(context, followUpDetails, List numbers,
      {required String type}) {
    numbers.removeWhere((element) => element.toString() == 'null');
    return Container(
      height: MySize.size36,
      child: PopupMenuButton<String>(
        icon: Icon(
          (type == 'call') ? MdiIcons.phone : MdiIcons.whatsapp,
          color:
              (type == 'call') ? themeData.colorScheme.primary : Colors.green,
        ),
        onSelected: (value) async {
          if (type == 'call') {
            await launch('tel:$value');
          }

          if (type == 'whatsApp') {
            await launch("https://wa.me/$value");
          }
        },
        itemBuilder: (BuildContext context) {
          return numbers.map((item) {
            return PopupMenuItem<String>(
              value: item,
              child: Text(
                '$item',
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  //noData widget
  noDataWidget(context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: CachedNetworkImage(
            imageUrl: Config().noDataImage,
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/noData.png'),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            AppLocalizations.of(context).translate('no_data'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.headlineMedium,
              fontWeight: 600,
              color: themeData.colorScheme.onSurface,
            ),
          ),
        )
      ],
    );
  }
}
