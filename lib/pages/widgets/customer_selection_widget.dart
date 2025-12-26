import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../models/contact_model.dart';

class CustomerSelectionWidget extends StatefulWidget {
  final Map<String, dynamic> selectedCustomer;
  final Function(Map<String, dynamic>) onCustomerSelected;
  final int? initialCustomerId;

  const CustomerSelectionWidget({
    Key? key,
    required this.selectedCustomer,
    required this.onCustomerSelected,
    this.initialCustomerId,
  }) : super(key: key);

  @override
  CustomerSelectionWidgetState createState() => CustomerSelectionWidgetState();
}

class CustomerSelectionWidgetState extends State<CustomerSelectionWidget> {
  List<Map<String, dynamic>> customerListMap = [];
  late Map<String, dynamic> selectedCustomer;
  
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.selectedCustomer;
    _loadCustomers();
    if (widget.initialCustomerId != null) {
      _loadInitialCustomer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SearchChoices.single(
        underline: Visibility(
          child: Container(),
          visible: false,
        ),
        displayClearIcon: false,
        value: jsonEncode(selectedCustomer),
        items: customerListMap.map<DropdownMenuItem<String>>((Map value) {
          return DropdownMenuItem<String>(
            value: jsonEncode(value),
            child: Container(
              width: MySize.screenWidth! * 0.8,
              child: Text(
                "${value['name']} (${value['mobile'] ?? ' - '})",
                softWrap: true,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
        iconEnabledColor: Colors.blue,
        iconDisabledColor: Colors.black,
        onChanged: (newValue) {
          setState(() {
            selectedCustomer = jsonDecode(newValue);
            widget.onCustomerSelected(selectedCustomer);
          });
        },
        isExpanded: true,
      ),
    );
  }

  Future<void> _loadCustomers() async {
    customerListMap = [
      {'id': 0, 'name': 'select customer', 'mobile': ' - '}
    ];
    
    List customers = await Contact().get();
    customers.forEach((value) {
      setState(() {
        customerListMap.add({
          'id': value['id'],
          'name': value['name'],
          'mobile': value['mobile']
        });
      });
      
      if (value['name'] == 'Walk-In Customer') {
        selectedCustomer = {
          'id': value['id'],
          'name': value['name'],
          'mobile': value['mobile']
        };
        widget.onCustomerSelected(selectedCustomer);
      }
    });
  }

  Future<void> _loadInitialCustomer() async {
    Future.delayed(Duration(milliseconds: 400), () async {
      await Contact()
          .getCustomerDetailById(widget.initialCustomerId!)
          .then((value) {
        if (mounted) {
          setState(() {
            selectedCustomer = {
              'id': widget.initialCustomerId!,
              'name': value['name'],
              'mobile': value['mobile']
            };
            widget.onCustomerSelected(selectedCustomer);
          });
        }
      });
    });
  }

  void refreshCustomers() {
    _loadCustomers();
  }
}