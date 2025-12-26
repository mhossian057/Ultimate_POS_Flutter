import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../locale/MyLocalizations.dart';
import '../models/sell.dart';
import 'login.dart';
import 'widgets/customer_selection_widget.dart';
import 'widgets/customer_create_form.dart';
import 'widgets/customer_bottom_bar.dart';
import 'widgets/customer_quotation_dialog.dart';
import 'widgets/customer_cart_product_list.dart';

class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  Map<String, dynamic>? argument;
  String transactionDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  Map<String, dynamic> selectedCustomer = {
    'id': 0,
    'name': 'select customer',
    'mobile': ' - '
  };

  final GlobalKey<CustomerSelectionWidgetState> _customerSelectionKey = 
      GlobalKey<CustomerSelectionWidgetState>();

  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map) {
      argument = Map<String, dynamic>.from(args);
      debugPrint('Customer screen received arguments: $argument');
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('customer'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.headlineSmall,
            fontWeight: 600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewCustomerForm,
        child: Icon(MdiIcons.accountPlus),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MySize.size120!,
                left: MySize.size20!,
              ),
              child: CustomerSelectionWidget(
                key: _customerSelectionKey,
                selectedCustomer: selectedCustomer,
                onCustomerSelected: _onCustomerSelected,
                initialCustomerId: argument?['customerId'],
              ),
            ),
            Center(
              child: Visibility(
                visible: (selectedCustomer['id'] == 0),
                child: Text(
                  AppLocalizations.of(context).translate(
                    'please_select_a_customer_for_checkout_option',
                  ),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            
            // Cart Product List - visible only when customer is selected
            if (selectedCustomer['id'] != 0)
              Padding(
                padding: EdgeInsets.only(
                  top: MySize.size20!,
                  left: MySize.size16!,
                  right: MySize.size16!,
                  bottom: MySize.size20!,
                ),
                child: CustomerCartProductList(
                  key: ValueKey('cart_${selectedCustomer['id']}'),
                  sellId: argument?['sellId'], // Can be null - widget will load from locationId
                  locationId: argument?['locationId'],
                  customerId: selectedCustomer['id'] ?? 0,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerBottomBar(
        selectedCustomer: selectedCustomer,
        argument: argument,
        onAddQuotation: _addQuotation,
      ),
    );
  }

  void _onCustomerSelected(Map<String, dynamic> customer) {
    debugPrint('Customer selected: ${customer['name']} (ID: ${customer['id']})');
    debugPrint('Cart will show - loading from locationId: ${argument?['locationId']} (sellId: ${argument?['sellId']})');
    setState(() {
      selectedCustomer = customer;
    });
  }

  void _showNewCustomerForm() {
    Navigator.of(context).push(
      MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return CustomerCreateForm(
            onCustomerCreated: _onCustomerCreated,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  void _onCustomerCreated() {
    _customerSelectionKey.currentState?.refreshCustomers();
  }

  Future<void> _addQuotation() async {
    Map<String, dynamic> sell = await Sell().createSell(
      changeReturn: 0.00,
      transactionDate: transactionDate,
      pending: argument!['invoiceAmount'],
      shippingCharges: 0.00,
      shippingDetails: '',
      invoiceNo: USERID.toString() + "_" + DateFormat('yMdHm').format(DateTime.now()),
      contactId: selectedCustomer['id'],
      discountAmount: argument!['discountAmount'],
      discountType: argument!['discountType'],
      invoiceAmount: argument!['invoiceAmount'],
      locId: argument!['locationId'],
      saleStatus: 'draft',
      sellId: argument!['sellId'],
      taxId: argument!['taxId'],
      isQuotation: 1,
    );
    _showConfirmDialog(sell);
  }

  void _showConfirmDialog(Map<String, dynamic> sell) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CustomerQuotationDialog(
          sell: sell,
          argument: argument,
        );
      },
    );
  }
}