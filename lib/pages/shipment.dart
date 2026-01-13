import 'dart:ui';

// import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apis/api.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../apis/shipment.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/shipment.dart';
// import 'googleMap.dart';

class Shipment extends StatefulWidget {
  @override
  _ShipmentState createState() => _ShipmentState();
}

class _ShipmentState extends State<Shipment> {
  List<String>? shipmentStatus;
  DateTime selectedDate = DateTime.now();
  String? nextPage = '', selectedStatus = '', selectedInlineStatus;
  List<dynamic> shipments = [];
  bool isLoading = true;
  String? errorMessage;
  TextEditingController deliveredToController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    print('Shipment: initState started');
    try {
      shipmentStatus = ShipmentModel().shipmentStatus;
      selectedStatus = shipmentStatus![0];
      print('Shipment: Status initialized - $selectedStatus');
      getShipments();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          generateShipmentList();
        }
      });
    } catch (e) {
      print('Shipment: Error in initState - $e');
    }
  }

  getShipments() async {
    try {
      var date = selectedDate.toLocal().toString().split(' ')[0];
      nextPage = Api().apiUrl +
          "sell/?start_date=$date"
              "&shipping_status=$selectedStatus";
      print('Shipment: API URL - $nextPage');
      generateShipmentList();
    } catch (e) {
      print('Shipment: Error in getShipments - $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    deliveredToController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Shipment: Building UI - isLoading: $isLoading, shipments count: ${shipments.length}');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(AppLocalizations.of(context).translate('shipment'),
            style: AppTheme.getTextStyle(themeData.textTheme.headlineSmall,
                fontWeight: 600)),
      ),
      body: errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 20),
                  Text('Error: $errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        errorMessage = null;
                        isLoading = true;
                        shipments = [];
                        getShipments();
                      });
                    },
                    child: Text('Retry'),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MySize.size20!,
                        top: MySize.size5!,
                        bottom: MySize.size10!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        status(),
                        shipmentDatePicker(),
                        // locateShipments()
                      ],
                    ),
                  ),
                  isLoading && shipments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(MySize.size50!),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : shipments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(MySize.size50!),
                                child: Text(
                                  'No shipments found',
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.titleLarge),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: shipments.length,
                              itemBuilder: (context, index) {
                                return block(index, shipments[index]['id'],
                                    invoiceNo: shipments[index]['invoice_no'],
                                    date: shipments[index]['transaction_date'],
                                    customerName: shipments[index]
                                        ['customerName'],
                                    status: shipments[index]['shipping_status'],
                                    deliverTo: shipments[index]['delivered_to'],
                                    contactNo: shipments[index]['contact_no']);
                              })
                ],
              ),
            ),
    );
  }

  //locate shipments in map
  Widget locateShipments() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: StadiumBorder(side: BorderSide(color: customAppTheme.bgLayer3)),
      ),
      onPressed: () => Navigator.pushNamed(context, '/google_map'),
      child: Text('Map',
          style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
              color: themeData.colorScheme.onBackground)),
    );
  }

  //date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        shipments = [];
        isLoading = true;
        errorMessage = null;
        getShipments();
      });
  }

  //widget shipment
  Widget status() {
    return PopupMenuButton(
        onSelected: (String? item) {
          setState(() {
            selectedStatus = item;
            shipments = [];
            isLoading = true;
            errorMessage = null;
            getShipments();
          });
        },
        itemBuilder: (BuildContext context) {
          return shipmentStatus!.map((String value) {
            return PopupMenuItem(
              value: value,
              height: MySize.size36!,
              child: Text(value,
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                      color: themeData.colorScheme.onBackground)),
            );
          }).toList();
        },
        color: themeData.colorScheme.surface,
        child: Container(
          padding: EdgeInsets.only(
              left: MySize.size12!,
              right: MySize.size12!,
              top: MySize.size8!,
              bottom: MySize.size8!),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size20!)),
            color: customAppTheme.bgLayer1,
            border: Border.all(color: customAppTheme.bgLayer3),
          ),
          child: Row(
            children: <Widget>[
              Text(
                selectedStatus!,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  color: themeData.colorScheme.onBackground,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: MySize.size4!),
                child: Icon(
                  MdiIcons.chevronDown,
                  size: MySize.size22,
                  color: themeData.colorScheme.onBackground,
                ),
              )
            ],
          ),
        ));
  }

  //inline status
  //widget shipment
  Widget inlineStatus() {
    return PopupMenuButton(
      onSelected: (String? item) {
        setState(() {
          selectedInlineStatus = item;
        });
      },
      itemBuilder: (BuildContext context) {
        return shipmentStatus!.map((String value) {
          return PopupMenuItem(
            value: value,
            height: MySize.size36!,
            child: Text(value,
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                    color: themeData.colorScheme.onBackground)),
          );
        }).toList();
      },
      color: themeData.colorScheme.surface,
      child: Container(
        padding: EdgeInsets.only(
            left: MySize.size12!,
            right: MySize.size12!,
            top: MySize.size8!,
            bottom: MySize.size8!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer3, width: 1),
        ),
        child: Row(
          children: <Widget>[
            Text(
              selectedInlineStatus!,
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyLarge,
                color: themeData.colorScheme.onBackground,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: MySize.size4!),
              child: Icon(
                MdiIcons.chevronDown,
                size: MySize.size22,
                color: themeData.colorScheme.onBackground,
              ),
            )
          ],
        ),
      ),
    );
  }

  //get customer name by contact_id
  Future<Map<String, dynamic>> getCustomerNameById(int id) async {
    var customer = await Contact().getCustomerDetailById(id);
    Map<String, dynamic> customerName = {
      'name': customer['name'],
      'mobile': customer['mobile']
    };
    return customerName;
  }

//date picker
  Widget shipmentDatePicker() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: StadiumBorder(side: BorderSide(color: customAppTheme.bgLayer3)),
      ),
      onPressed: () => _selectDate(context),
      child: Text("${selectedDate.toLocal()}".split(' ')[0]),
    );
  }

// shipment block
  Widget block(int index, int id,
      {invoiceNo, date, customerName, deliverTo, contactNo, status}) {
    return Card(
      margin: EdgeInsets.all(MySize.size10!),
      elevation: 2,
      shadowColor: Colors.grey,
      child: Container(
        padding: EdgeInsets.all(MySize.size5!),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${invoiceNo ?? "N/A"}',
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleMedium,
                        fontWeight: 600,
                        color: themeData.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      MdiIcons.accountBoxOutline,
                      color: Colors.blueGrey.shade600,
                    ),
                    Text(
                      " ${customerName ?? 'N/A'}",
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleMedium,
                        fontWeight: 600,
                        color: themeData.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      MdiIcons.calendarClock,
                      color: Colors.green.shade900,
                    ),
                    Text(
                      ' ${date ?? "N/A"}',
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.titleMedium,
                        color: themeData.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (contactNo != null && contactNo != 'N/A') {
                              launch("tel:$contactNo");
                            }
                            // CustomerApi().getLeads();
                            // var now = DateTime.now();int from = now.subtract(Duration(days: 1)).millisecondsSinceEpoch;int to = now.subtract(Duration(days: 0)).millisecondsSinceEpoch;

                            // Iterable<CallLogEntry> result = await CallLog.query(dateFrom: from, dateTo: to, number: '$contactNo');result.forEach((element) {print(element.formattedNumber);print(element.cachedMatchedNumber);print(element.number);print(element.name);print(element.callType);print(element.timestamp);print(element.duration);});
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.call_outlined,
                                color: Colors.lightBlue,
                              ),
                              Text(
                                ' ${contactNo ?? "N/A"}',
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          child: Row(
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                color: Colors.yellow.shade900,
                              ),
                              Text(
                                ' ${deliverTo ?? "N/A"}',
                                style: AppTheme.getTextStyle(
                                  themeData.textTheme.headlineSmall,
                                  fontWeight: 700,
                                  color: themeData.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          visible: (deliverTo != null &&
                              deliverTo != 'N/A' &&
                              deliverTo.toString().trim() != ''),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        selectedInlineStatus =
                            shipments[index]['shipping_status'];
                        deliveredToController.text =
                            shipments[index]['delivered_to'] ?? '';
                        shippingDialog(index,
                            details: shipments[index]['shipping_details'] ?? '',
                            address:
                                shipments[index]['shipping_address'] ?? '');
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: MySize.size2!),
                          padding: EdgeInsets.all(MySize.size4!),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset.zero,
                                    color: customAppTheme.bgLayer3)
                              ],
                              borderRadius: BorderRadius.all(
                                  Radius.circular(MySize.size20!)),
                              border:
                                  Border.all(color: customAppTheme.bgLayer3)),
                          child: Text(
                            (status ?? 'N/A').toString().toUpperCase(),
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyLarge,
                              color: themeData.colorScheme.onBackground,
                            ),
                          )),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      MdiIcons.googleMaps,
                      color: Colors.red,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: MySize.size2!),
                      width: MySize.screenWidth! * 0.8,
                      child: Text(
                        '${shipments[index]['shipping_address'] ?? 'N/A'}',
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyLarge,
                          color: themeData.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Container(alignment: Alignment.topRight, child: GestureDetector(child: Icon(Icons.directions, color: Colors.green, size: MySize.size40,), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Direction(shipments[index]['shipping_address'])));},),)
          ],
        ),
      ),
    );
  }

  //Retrieve shipment list from api
  //generate shipment list
  generateShipmentList() async {
    print('Shipment: generateShipmentList started');
    try {
      if (nextPage != null && nextPage!.isNotEmpty) {
        print('Shipment: Making API call to - $nextPage');

        // Use ShipmentApi instead of Dio
        var result = await ShipmentApi().getShipments(nextPage!);

        if (result != null) {
          print('Shipment: API Response received');
          print('Shipment: Response data - $result');

          Map links = result['links'];
          nextPage = links['next'];
          List shipment = result['data'];
          print('Shipment: Found ${shipment.length} shipments');

          // Process all shipments
          for (var element in shipment) {
            try {
              // Use contact data directly from API response instead of querying database
              var contactData = element['contact'];

              print('Shipment: Processing shipment ID ${element['id']}, Invoice: ${element['invoice_no']}');
              print('Shipment: Contact data available: ${contactData != null}');

              if (mounted) {
                setState(() {
                  shipments.add({
                    'id': element['id'] ?? 0,
                    'invoice_no': element['invoice_no'] ?? 'N/A',
                    'customerName': contactData != null ? (contactData['name'] ?? 'N/A') : 'N/A',
                    'transaction_date': element['transaction_date'] ?? 'N/A',
                    'shipping_status': element['shipping_status'] ?? 'N/A',
                    'shipping_details': element['shipping_details'] ?? 'N/A',
                    'shipping_address': element['shipping_address'] ?? 'N/A',
                    'delivered_to': element['delivered_to'] ?? 'N/A',
                    'contact_no': contactData != null ? (contactData['mobile'] ?? 'N/A') : 'N/A',
                  });
                });
              }
              print('Shipment: Successfully added shipment to list');
            } catch (e) {
              print('Shipment: Error processing shipment item - $e');
              print('Shipment: Error details - ${e.toString()}');
            }
          }

          // Set loading to false after all items are processed
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          print('Shipment: All shipments processed');
        } else {
          print('Shipment: API returned null');
          if (mounted) {
            setState(() {
              isLoading = false;
              errorMessage = 'Failed to fetch shipments. Please check your connection.';
            });
          }
        }
      } else {
        print('Shipment: nextPage is null or empty');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Shipment: Error in generateShipmentList - $e');
      print('Shipment: Stack trace - ${StackTrace.current}');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  shippingDialog(int index, {String? details, String? address}) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${shipments[index]['invoice_no'] ?? 'N/A'}"),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      "${AppLocalizations.of(context).translate('shipping_details')} : ",
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyLarge,
                          fontWeight: 600),
                    ),
                    subtitle: Text(
                      '${details ?? "N/A"}',
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyLarge,
                          fontWeight: 500),
                    ),
                    isThreeLine: true,
                  ),
                  ListTile(
                    title: Text(
                      "${AppLocalizations.of(context).translate('shipping_address')} : ",
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyLarge,
                          fontWeight: 600),
                    ),
                    subtitle: Text(
                      '${address ?? "N/A"}',
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.bodyLarge,
                          fontWeight: 500),
                    ),
                    isThreeLine: true,
                  ),
                  inlineStatus(),
                  Padding(
                    padding: EdgeInsets.only(top: MySize.size8!),
                    child: TextFormField(
                      controller: deliveredToController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('delivered_to'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                onPressed: () async {
                  var data = ShipmentModel().updateShipment(
                      id: shipments[index]['id'],
                      status: selectedInlineStatus,
                      deliveredTo: deliveredToController.text);
                  await ShipmentApi().updateShipmentStatus(data).then((value) {
                    selectedInlineStatus = null;
                    Navigator.pop(context);
                    if (this.mounted) {
                      setState(() {
                        shipments = [];
                        getShipments();
                      });
                    }
                  });
                },
                child: Text(AppLocalizations.of(context).translate('save')),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).translate('cancel')))
            ],
          );
        });
  }
}
