import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../locale/MyLocalizations.dart';
import 'filter_dropdown_widgets.dart';

class SalesFilterWidget extends StatelessWidget {
  final bool showFilter;
  final Map<dynamic, dynamic> selectedLocation;
  final Map<dynamic, dynamic> selectedCustomer;
  final String? startDateRange;
  final String? endDateRange;
  final String selectedPaymentStatus;
  final List<Map<dynamic, dynamic>> locationListMap;
  final List<Map<dynamic, dynamic>> customerListMap;
  final List<String> paymentStatuses;
  final Function() onToggleFilter;
  final Function(Map<dynamic, dynamic>) onLocationChanged;
  final Function(Map<dynamic, dynamic>) onCustomerChanged;
  final Function() onDateRangePressed;
  final Function(String) onPaymentStatusChanged;
  final Function() onReset;
  final Function() onApply;
  final ThemeData themeData;
  final CustomAppTheme customAppTheme;

  const SalesFilterWidget({
    Key? key,
    required this.showFilter,
    required this.selectedLocation,
    required this.selectedCustomer,
    required this.startDateRange,
    required this.endDateRange,
    required this.selectedPaymentStatus,
    required this.locationListMap,
    required this.customerListMap,
    required this.paymentStatuses,
    required this.onToggleFilter,
    required this.onLocationChanged,
    required this.onCustomerChanged,
    required this.onDateRangePressed,
    required this.onPaymentStatusChanged,
    required this.onReset,
    required this.onApply,
    required this.themeData,
    required this.customAppTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleFilter,
      child: Container(
        padding: EdgeInsets.all(MySize.size12!),
        margin: EdgeInsets.all(MySize.size12!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
          color: customAppTheme.bgLayer1,
          border: Border.all(color: customAppTheme.bgLayer4, width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  showFilter ? MdiIcons.chevronUp : MdiIcons.chevronDown,
                  color: themeData.colorScheme.primary,
                ),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('filter'),
                      style: AppTheme.getTextStyle(
                          themeData.textTheme.headlineSmall,
                          color: themeData.colorScheme.primary,
                          fontWeight: 700),
                    ),
                    Icon(
                      MdiIcons.filter,
                      color: themeData.colorScheme.primary,
                    )
                  ],
                ),
              ],
            ),
            if (showFilter) _buildFilterContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "${AppLocalizations.of(context).translate('location')} : ",
              style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  fontWeight: 600),
            ),
            FilterDropdownWidgets.buildLocationDropdown(
              selectedLocation,
              locationListMap,
              onLocationChanged,
              themeData,
              customAppTheme,
            )
          ],
        ),
        Row(
          children: [
            Text(
              "${AppLocalizations.of(context).translate('customer')} : ",
              style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  fontWeight: 600),
            ),
            Expanded(
              child: FilterDropdownWidgets.buildCustomerDropdown(
                selectedCustomer,
                customerListMap,
                onCustomerChanged,
                themeData,
              ),
            )
          ],
        ),
        FilterDropdownWidgets.buildDateRangePicker(
          startDateRange,
          endDateRange,
          onDateRangePressed,
          themeData,
          customAppTheme,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.size6!),
        ),
        Row(
          children: [
            Text(
              "${AppLocalizations.of(context).translate('payment_status')} : ",
              style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  fontWeight: 600),
            ),
            if (paymentStatuses.length > 0)
              FilterDropdownWidgets.buildPaymentStatusDropdown(
                selectedPaymentStatus,
                paymentStatuses,
                onPaymentStatusChanged,
                themeData,
                customAppTheme,
                context,
              )
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.size6!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size20!),
                    side: BorderSide(color: themeData.colorScheme.primary)),
                foregroundColor: themeData.colorScheme.primary,
              ),
              child: Text(
                AppLocalizations.of(context).translate('reset'),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.labelLarge,
                    color: themeData.colorScheme.onPrimary,
                    fontWeight: 600),
              ),
              onPressed: onReset,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.size20!),
                    side: BorderSide(color: themeData.colorScheme.primary)),
                foregroundColor: themeData.colorScheme.primary,
              ),
              child: Text(
                AppLocalizations.of(context).translate('ok'),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.labelLarge,
                    color: themeData.colorScheme.onPrimary,
                    fontWeight: 600),
              ),
              onPressed: onApply,
            ),
          ],
        )
      ],
    );
  }
}