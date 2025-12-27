import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:search_choices/search_choices.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../locale/MyLocalizations.dart';

class FilterDropdownWidgets {
  static Widget buildLocationDropdown(
    Map<dynamic, dynamic> selectedLocation,
    List<Map<dynamic, dynamic>> locationListMap,
    Function(Map<dynamic, dynamic>) onLocationChanged,
    ThemeData themeData,
    CustomAppTheme customAppTheme,
  ) {
    return PopupMenuButton(
      onSelected: onLocationChanged,
      itemBuilder: (BuildContext context) {
        return locationListMap.map((Map value) {
          return PopupMenuItem(
            value: value,
            child: Text(value['name'],
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                    color: themeData.colorScheme.onBackground)),
          );
        }).toList();
      },
      color: themeData.colorScheme.surface,
      child: Container(
        padding: EdgeInsets.all(MySize.size8!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer3, width: 1),
        ),
        child: Row(
          children: <Widget>[
            Text(
              selectedLocation['name'],
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

  static Widget buildCustomerDropdown(
    Map<dynamic, dynamic> selectedCustomer,
    List<Map<dynamic, dynamic>> customerListMap,
    Function(Map<dynamic, dynamic>) onCustomerChanged,
    ThemeData themeData,
  ) {
    return SearchChoices.single(
      underline: Visibility(child: Container(), visible: false),
      displayClearIcon: false,
      value: jsonEncode(selectedCustomer),
      items: customerListMap.map<DropdownMenuItem<String>>((Map value) {
        return DropdownMenuItem<String>(
            value: jsonEncode(value),
            child: Container(
              width: MySize.screenWidth! * 0.8,
              child: Text("${value['name']} (${value['mobile'] ?? ' - '})",
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                      color: themeData.colorScheme.onBackground)),
            ));
      }).toList(),
      onChanged: (value) async {
        if (value != null) {
          onCustomerChanged(jsonDecode(value));
        }
      },
      isExpanded: true,
    );
  }

  static Widget buildDateRangePicker(
    String? startDateRange,
    String? endDateRange,
    Function() onDateRangePressed,
    ThemeData themeData,
    CustomAppTheme customAppTheme,
  ) {
    return GestureDetector(
      onTap: onDateRangePressed,
      child: Container(
        padding: EdgeInsets.all(MySize.size8!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer4, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                (startDateRange != null && endDateRange != null)
                    ? "$startDateRange   -   $endDateRange"
                    : "Date range",
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    fontWeight: 600)),
          ],
        ),
      ),
    );
  }

  static Widget buildPaymentStatusDropdown(
    String selectedPaymentStatus,
    List<String> paymentStatuses,
    Function(String) onPaymentStatusChanged,
    ThemeData themeData,
    CustomAppTheme customAppTheme,
    BuildContext context,
  ) {
    return PopupMenuButton(
      onSelected: onPaymentStatusChanged,
      itemBuilder: (BuildContext context) {
        return paymentStatuses.map((String value) {
          return PopupMenuItem(
            value: value,
            child: Text(
                AppLocalizations.of(context).translate(value).toUpperCase(),
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                    color: themeData.colorScheme.onBackground)),
          );
        }).toList();
      },
      color: themeData.colorScheme.surface,
      child: Container(
        padding: EdgeInsets.all(MySize.size8!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer3, width: 1),
        ),
        child: Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context)
                  .translate(selectedPaymentStatus)
                  .toUpperCase(),
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
}