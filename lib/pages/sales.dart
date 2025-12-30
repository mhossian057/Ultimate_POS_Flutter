import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../apis/api.dart';
import '../apis/sell.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/sell.dart';
import '../models/sellDatabase.dart';
import '../models/system.dart';
import '../pages/login.dart';
import '../helpers/dio_logger.dart';
import 'elements.dart';
import 'widgets/sales/sales_filter_widget.dart';
import 'widgets/sales/recent_sales_item.dart';
import 'widgets/sales/all_sales_item.dart';
import 'widgets/sales/date_range_picker.dart';
import 'widgets/sales/sales_shimmer_widget.dart';

class Sales extends StatefulWidget {
  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List sellList = [];
  List<String> paymentStatuses = ['all'], invoiceStatuses = ['final', 'draft'];
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false,
      synced = true,
      canViewSell = false,
      canEditSell = false,
      canDeleteSell = false,
      showFilter = false,
      changeUrl = false,
      isLoadingPermissions = true,
      isLoadingData = false;
  Set<int> printingItems = {};
  Set<int> sharingItems = {};
  Set<int> printingAllSalesItems = {};
  Set<int> sharingAllSalesItems = {};
  Map<dynamic, dynamic> selectedLocation = {'id': 0, 'name': 'All'},
      selectedCustomer = {'id': 0, 'name': 'All', 'mobile': ''};
  String selectedPaymentStatus = 'all';
  String? startDateRange, endDateRange;
  List<Map<dynamic, dynamic>> allSalesListMap = [],
      customerListMap = [
        {'id': 0, 'name': 'All', 'mobile': ''}
      ],
      locationListMap = [
        {'id': 0, 'name': 'All'}
      ];
  String symbol = '';
  String? nextPage = '', url = Api().apiUrl + "sell?order_by_date=desc";
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    setCustomers();
    setLocations();
    if ((synced)) refreshSales();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setAllSalesList();
      }
    });
    Helper().syncCallLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  setCustomers() async {
    customerListMap.addAll(await Contact().get());
    if (mounted) setState(() {});
  }

  setLocations() async {
    await System().get('location').then((value) {
      value.forEach((element) {
        if (mounted) {
          setState(() {
            locationListMap.add({
              'id': element['id'],
              'name': element['name'],
            });
          });
        }
      });
    });
    await System().refreshPermissionList().then((value) async {
      await getPermission().then((value) {
        changeUrl = true;
        onFilter();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context).translate('sales'),
              style: AppTheme.getTextStyle(themeData.textTheme.headlineSmall,
                  fontWeight: 600)),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (await Helper().checkConnectivity()) {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(AppLocalizations.of(context)
                                    .translate('sync_in_progress'))),
                          ],
                        ),
                      );
                    },
                  );
                  await Sell().createApiSell(syncAll: true).then((value) {
                    Navigator.pop(context);
                    setState(() {
                      synced = true;
                      sells();
                    });
                  });
                } else
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)
                          .translate('check_connectivity'));
              },
              child: Text(
                AppLocalizations.of(context).translate('sync'),
                style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
                    fontWeight: (synced) ? 500 : 900, letterSpacing: -0.2),
              ),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(
                icon: Icon(Icons.line_weight),
                child: Text(
                    AppLocalizations.of(context).translate('recent_sales'))),
            Tab(
              icon: Icon(Icons.line_style),
              child: Text(AppLocalizations.of(context).translate('all_sales')),
            )
          ]),
        ),
        body: TabBarView(children: [currentSales(), allSales()]),
        bottomNavigationBar: posBottomBar('sale', context),
      ),
    );
  }

  Widget currentSales() {
    return (sellList.length > 0)
        ? ListView.builder(
            padding: EdgeInsets.all(10),
            controller: _scrollController,
            itemCount: sellList.length,
            itemBuilder: (context, index) {
              return RecentSalesItem(
                sellItem: sellList[index],
                index: index,
                symbol: symbol,
                canEditSell: canEditSell,
                canDeleteSell: canDeleteSell,
                printingItems: printingItems,
                sharingItems: sharingItems,
                onPrintingStateChanged: _handlePrintingStateChanged,
                onSharingStateChanged: _handleSharingStateChanged,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
                onPayment: _handlePayment,
                themeData: themeData,
                customAppTheme: customAppTheme,
              );
            })
        : Helper().noDataWidget(context);
  }

  Widget allSales() {
    if (isLoadingPermissions || (canViewSell && isLoadingData)) {
      return Column(
        children: [
          // Show filter shimmer
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MySize.size16!,
              vertical: MySize.size8!,
            ),
            height: 60,
            decoration: BoxDecoration(
              color: customAppTheme.bgLayer1,
              borderRadius: BorderRadius.circular(MySize.size16!),
              border: Border.all(
                color: customAppTheme.bgLayer4,
                width: 1.5,
              ),
            ),
          ),
          // Show sales shimmer
          Expanded(child: SalesShimmerList()),
        ],
      );
    }
    
    return (canViewSell)
        ? Column(
            children: [
              SalesFilterWidget(
                showFilter: showFilter,
                selectedLocation: selectedLocation,
                selectedCustomer: selectedCustomer,
                startDateRange: startDateRange,
                endDateRange: endDateRange,
                selectedPaymentStatus: selectedPaymentStatus,
                locationListMap: locationListMap,
                customerListMap: customerListMap,
                paymentStatuses: paymentStatuses,
                onToggleFilter: () {
                  setState(() {
                    showFilter = !showFilter;
                  });
                },
                onLocationChanged: (Map<dynamic, dynamic> location) {
                  if (mounted) {
                    setState(() {
                      selectedLocation = location;
                    });
                  }
                  onFilter();
                },
                onCustomerChanged: (Map<dynamic, dynamic> customer) {
                  if (mounted) {
                    setState(() {
                      selectedCustomer = customer;
                    });
                  }
                  onFilter();
                },
                onDateRangePressed: _openDateRangePicker,
                onPaymentStatusChanged: (String status) {
                  if (mounted) {
                    setState(() {
                      selectedPaymentStatus = status;
                    });
                  }
                  onFilter();
                },
                onReset: () {
                  setState(() {
                    selectedLocation = locationListMap[0];
                    selectedCustomer = customerListMap[0];
                    startDateRange = null;
                    endDateRange = null;
                    // Reset to 'all' if available, otherwise first item
                    selectedPaymentStatus = paymentStatuses.contains('all') ? 'all' : paymentStatuses[0];
                  });
                  onFilter();
                },
                onApply: onFilter,
                themeData: themeData,
                customAppTheme: customAppTheme,
              ),
              Expanded(
                child: (allSalesListMap.length > 0)
                    ? ListView.builder(
                        padding: EdgeInsets.all(10),
                        controller: _scrollController,
                        itemCount: allSalesListMap.length + 1,
                        itemBuilder: (context, index) {
                          if (index == allSalesListMap.length) {
                            return (isLoading)
                                ? _buildProgressIndicator()
                                : Container();
                          } else {
                            return AllSalesItem(
                              salesItem: Map<String, dynamic>.from(
                                  allSalesListMap[index]),
                              index: index,
                              symbol: symbol,
                              canDeleteSell: canDeleteSell,
                              printingAllSalesItems: printingAllSalesItems,
                              sharingAllSalesItems: sharingAllSalesItems,
                              onPrintingStateChanged:
                                  _handleAllSalesPrintingStateChanged,
                              onSharingStateChanged:
                                  _handleAllSalesSharingStateChanged,
                              onDeleteItem: _handleAllSalesDelete,
                              themeData: themeData,
                              customAppTheme: customAppTheme,
                            );
                          }
                        })
                    : isLoadingData 
                        ? SalesShimmerList()  // Still loading data
                        : Helper().noDataWidget(context),  // Actually no data
              )
            ],
          )
        : Center(
            child: Text(
              AppLocalizations.of(context).translate('unauthorised'),
              style: TextStyle(color: Colors.black),
            ),
          );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: FutureBuilder<bool>(
            future: Helper().checkConnectivity(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == false) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .translate('check_connectivity'),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.titleMedium,
                          fontWeight: 700,
                          letterSpacing: -0.2),
                    ),
                    Icon(
                      Icons.error_outline,
                      color: themeData.colorScheme.onBackground,
                    )
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  void _openDateRangePicker() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute<Map<String, String?>>(
            builder: (BuildContext context) {
              return DateRangePickerScreen(
                startDateRange: startDateRange,
                endDateRange: endDateRange,
                themeData: themeData,
              );
            },
            fullscreenDialog: true));

    if (result != null) {
      setState(() {
        startDateRange = result['startDate'];
        endDateRange = result['endDate'];
      });
    }
  }

  void _handlePrintingStateChanged(int sellId) {
    setState(() {
      if (printingItems.contains(sellId)) {
        printingItems.remove(sellId);
      } else {
        printingItems.add(sellId);
      }
    });
  }

  void _handleSharingStateChanged(int sellId) {
    setState(() {
      if (sharingItems.contains(sellId)) {
        sharingItems.remove(sellId);
      } else {
        sharingItems.add(sellId);
      }
    });
  }

  void _handleAllSalesPrintingStateChanged(int sellId) {
    setState(() {
      if (printingAllSalesItems.contains(sellId)) {
        printingAllSalesItems.remove(sellId);
      } else {
        printingAllSalesItems.add(sellId);
      }
    });
  }

  void _handleAllSalesSharingStateChanged(int sellId) {
    setState(() {
      if (sharingAllSalesItems.contains(sellId)) {
        sharingAllSalesItems.remove(sellId);
      } else {
        sharingAllSalesItems.add(sellId);
      }
    });
  }

  void _handleAllSalesDelete(int index) {
    setState(() {
      allSalesListMap.removeAt(index);
    });
  }

  void _handleEdit(BuildContext context, Map<String, dynamic> sellItem) {
    Navigator.pushNamed(context, '/cart',
        arguments: Helper().argument(
            locId: sellItem['location_id'],
            sellId: sellItem['id'],
            isQuotation: sellItem['is_quotation']));
  }

  void _handleDelete(BuildContext context, Map<String, dynamic> sellItem) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.warning,
            color: Colors.red,
            size: MySize.size50,
          ),
          content: Text(AppLocalizations.of(context).translate('are_you_sure'),
              textAlign: TextAlign.center,
              style: AppTheme.getTextStyle(themeData.textTheme.bodyLarge,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  muted: true)),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: themeData.colorScheme.onPrimary,
                    foregroundColor: themeData.colorScheme.primary),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).translate('cancel'))),
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: themeData.colorScheme.onError),
                onPressed: () async {
                  Navigator.pop(context);
                  await SellDatabase().deleteSell(sellItem['id']);
                  await SellApi().delete(sellItem['transaction_id']);
                  sells();
                },
                child: Text(AppLocalizations.of(context).translate('ok')))
          ],
        );
      },
    );
  }

  void _handlePayment(BuildContext context, Map<String, dynamic> sellItem) {
    Navigator.pushNamed(context, '/checkout',
        arguments: Helper().argument(
            invoiceAmount: sellItem['invoice_amount'],
            customerId: sellItem['contact_id'],
            locId: sellItem['location_id'],
            discountAmount: sellItem['discount_amount'],
            discountType: sellItem['discount_type'],
            isQuotation: sellItem['is_quotation'],
            taxId: sellItem['tax_rate_id'],
            sellId: sellItem['id']));
  }

  // Continue with business logic methods...
  getPermission() async {
    var activeSubscriptionDetails = await System().get('active-subscription');
    if (activeSubscriptionDetails.length > 0) {
      if (await Helper().getPermission("sell.update")) {
        canEditSell = true;
      }
      if (await Helper().getPermission("sell.delete")) {
        canDeleteSell = true;
      }
    }
    // Check all payment status permissions and collect them
    if (await Helper().getPermission("view_paid_sells_only")) {
      paymentStatuses.add('paid');
    }
    if (await Helper().getPermission("view_due_sells_only")) {
      paymentStatuses.add('due');
    }
    if (await Helper().getPermission("view_partial_sells_only")) {
      paymentStatuses.add('partial');
    }
    if (await Helper().getPermission("view_overdue_sells_only")) {
      paymentStatuses.add('overdue');
    }
    
    // If user has multiple payment status permissions, default to 'all'
    // If user has only one specific permission, use that
    if (paymentStatuses.length > 2) {  // more than ['all', one_specific_status]
      selectedPaymentStatus = 'all';
    } else if (paymentStatuses.length == 2) {  // ['all', one_specific_status]
      selectedPaymentStatus = paymentStatuses[1]; // use the specific status
    }
    if (await Helper().getPermission("direct_sell.view")) {
      url = Api().apiUrl + "sell?order_by_date=desc";
      if (paymentStatuses.length < 2) {
        paymentStatuses.addAll(['paid', 'due', 'partial', 'overdue']);
        selectedPaymentStatus = 'all';
      }
      if (mounted) {
        setState(() {
          canViewSell = true;
        });
      }
    } else if (await Helper().getPermission("view_own_sell_only")) {
      url = Api().apiUrl + "sell?order_by_date=desc&user_id=$USERID";
      if (paymentStatuses.length < 2) {
        paymentStatuses.addAll(['paid', 'due', 'partial', 'overdue']);
        selectedPaymentStatus = 'all';
      }
      if (mounted) {
        setState(() {
          canViewSell = true;
        });
      }
    }
    
    // Mark permissions as loaded
    if (mounted) {
      setState(() {
        isLoadingPermissions = false;
      });
    }
  }

  refreshSales() async {
    if (await Helper().checkConnectivity()) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child:
                      Text(AppLocalizations.of(context).translate('loading')),
                ),
              ],
            ),
          );
        },
      );
      sells();
      Navigator.pop(context);
    } else {
      sells();
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('check_connectivity'));
    }
  }

  sells() async {
    sellList = [];
    await SellDatabase().getSells(all: true).then((value) {
      value.forEach((element) async {
        if (element['is_synced'] == 0) synced = false;
        var customerDetail =
            await Contact().getCustomerDetailById(element['contact_id']);
        var locationName =
            await Helper().getLocationNameById(element['location_id']);

        String status =
            checkStatus(element['invoice_amount'], element['pending_amount']);
        String paid = Helper().formatCurrency(
            element['invoice_amount'] - element['pending_amount']);

        setState(() {
          sellList.add({
            'id': element['id'],
            'transaction_date': element['transaction_date'],
            'invoice_no': element['invoice_no'],
            'customer_name': customerDetail['name'],
            'mobile': customerDetail['mobile'],
            'contact_id': element['contact_id'],
            'location_id': element['location_id'],
            'location_name': locationName,
            'status': status,
            'tax_rate_id': element['tax_rate_id'],
            'discount_amount': element['discount_amount'],
            'discount_type': element['discount_type'],
            'sale_note': element['sale_note'],
            'staff_note': element['staff_note'],
            'invoice_amount':
                Helper().formatCurrency(element['invoice_amount']),
            'pending_amount': element['pending_amount'],
            'paid_amount': paid,
            'is_synced': element['is_synced'],
            'is_quotation': element['is_quotation'],
            'invoice_url': element['invoice_url'],
            'transaction_id': element['transaction_id']
          });
        });
      });
    });
    await Helper().getFormattedBusinessDetails().then((value) {
      symbol = value['symbol'];
    });
  }

  String checkStatus(double invoiceAmount, double pendingAmount) {
    if (pendingAmount == invoiceAmount)
      return 'due';
    else if (pendingAmount >= 0.01)
      return 'partial';
    else
      return 'paid';
  }

  onFilter() {
    nextPage = url;
    if (selectedLocation['id'] != 0) {
      nextPage = nextPage! + "&location_id=${selectedLocation['id']}";
    }
    if (selectedCustomer['id'] != 0) {
      nextPage = nextPage! + "&contact_id=${selectedCustomer['id']}";
    }
    if (selectedPaymentStatus.isNotEmpty && selectedPaymentStatus != 'all') {
      nextPage = nextPage! + "&payment_status=$selectedPaymentStatus";
    } else if (selectedPaymentStatus == 'all' && paymentStatuses.length > 1) {
      List<String> status = List.from(paymentStatuses);
      status.remove('all');
      if (status.isNotEmpty) {
        String statuses = status.join(',');
        nextPage = nextPage! + "&payment_status=$statuses";
      }
    }
    if (startDateRange != null && endDateRange != null) {
      nextPage =
          nextPage! + "&start_date=$startDateRange&end_date=$endDateRange";
    }
    changeUrl = true;
    setAllSalesList();
  }

  void setAllSalesList() async {
    if (mounted) {
      setState(() {
        if (changeUrl) {
          allSalesListMap = [];
          changeUrl = false;
          showFilter = false;
          isLoadingData = true; // Only show shimmer for initial data load
        }
        isLoading = false;
      });
    }
    final dio = new Dio();
    dio.interceptors.add(ApiLoggerInterceptor());
    var token = await System().getToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer $token";
    final response = await dio.get(nextPage!);
    List sales = response.data['data'];
    Map links = response.data['links'];
    nextPage = links['next'];
    sales.forEach((sell) async {
      var paidAmount;
      List payments = sell['payment_lines'];
      double totalPaid = 0.00;
      Map<String, dynamic>? customer =
          await Contact().getCustomerDetailById(sell['contact_id']);
      var location = await Helper().getLocationNameById(sell['location_id']);
      payments.forEach((element) {
        totalPaid += double.parse(element['amount']);
      });
      (totalPaid <= double.parse(sell['final_total']))
          ? paidAmount = Helper().formatCurrency(totalPaid)
          : paidAmount = Helper().formatCurrency(sell['final_total']);
      allSalesListMap.add({
        'id': sell['id'],
        'location_name': location,
        'contact_name': (customer != null)
            ? ("${(customer['name'] != null) ? customer['name'] : ''} "
                "${(customer['supplier_business_name'] != null) ? customer['supplier_business_name'] : ''}")
            : null,
        'mobile': (customer != null) ? customer['mobile'] : null,
        'invoice_no': sell['invoice_no'],
        'invoice_url': sell['invoice_url'],
        'date_time': sell['transaction_date'],
        'invoice_amount': sell['final_total'],
        'status': sell['payment_status'] ?? sell['status'],
        'paid_amount': paidAmount,
        'is_quotation': sell['is_quotation'].toString(),
        'tax_rate_id': sell['tax_rate_id'] ?? 0
      });
      if (this.mounted) {
        setState(() {
          isLoading = true;
        });
      }
    });
    
    // Mark data loading as complete only if it was an initial load
    if (mounted) {
      setState(() {
        if (allSalesListMap.length <= sales.length) {
          // This was an initial load, not pagination
          isLoadingData = false;
        }
      });
    }
  }
}
