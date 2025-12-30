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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: MySize.size16!,
        vertical: MySize.size8!,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size16!),
        color: customAppTheme.bgLayer1,
        border: Border.all(
          color: showFilter 
              ? themeData.colorScheme.primary.withOpacity(0.3)
              : customAppTheme.bgLayer4,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleFilter,
            borderRadius: BorderRadius.circular(MySize.size16!),
            child: Padding(
              padding: EdgeInsets.all(MySize.size16!),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(MySize.size8!),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MySize.size8!),
                    ),
                    child: Icon(
                      MdiIcons.filter,
                      color: themeData.colorScheme.primary,
                      size: MySize.size20!,
                    ),
                  ),
                  SizedBox(width: MySize.size12!),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('filter'),
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.titleMedium,
                            color: themeData.colorScheme.onSurface,
                            fontWeight: 600,
                          ),
                        ),
                        if (!showFilter) _buildActiveFiltersPreview(context),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: showFilter ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      MdiIcons.chevronDown,
                      color: themeData.colorScheme.primary,
                      size: MySize.size24!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showFilter)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildFilterContent(context),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        MySize.size16!,
        0,
        MySize.size16!,
        MySize.size16!,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: customAppTheme.bgLayer4.withOpacity(0.5),
            margin: EdgeInsets.only(bottom: MySize.size16!),
          ),
          _buildFilterSection(
            context,
            AppLocalizations.of(context).translate('location'),
            MdiIcons.mapMarker,
            FilterDropdownWidgets.buildLocationDropdown(
              selectedLocation,
              locationListMap,
              onLocationChanged,
              themeData,
              customAppTheme,
            ),
          ),
          _buildFilterSection(
            context,
            AppLocalizations.of(context).translate('customer'),
            MdiIcons.account,
            FilterDropdownWidgets.buildCustomerDropdown(
              selectedCustomer,
              customerListMap,
              onCustomerChanged,
              themeData,
            ),
          ),
          _buildFilterSection(
            context,
            AppLocalizations.of(context).translate('date'),
            MdiIcons.calendar,
            FilterDropdownWidgets.buildDateRangePicker(
              startDateRange,
              endDateRange,
              onDateRangePressed,
              themeData,
              customAppTheme,
            ),
          ),
          _buildFilterSection(
            context,
            AppLocalizations.of(context).translate('payment_status'),
            MdiIcons.creditCard,
            paymentStatuses.length > 0
                ? FilterDropdownWidgets.buildPaymentStatusDropdown(
                    selectedPaymentStatus,
                    paymentStatuses,
                    onPaymentStatusChanged,
                    themeData,
                    customAppTheme,
                    context,
                  )
                : SizedBox.shrink(),
          ),
          SizedBox(height: MySize.size20!),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: Icon(
                      MdiIcons.refresh,
                      size: MySize.size18!,
                    ),
                    label: Text(
                      AppLocalizations.of(context).translate('reset'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.labelLarge,
                        fontWeight: 600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.size20!,
                        vertical: MySize.size12!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size12!),
                      ),
                      side: BorderSide(
                        color: themeData.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MySize.size12!),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApply,
                    icon: Icon(
                      MdiIcons.check,
                      size: MySize.size18!,
                    ),
                    label: Text(
                      AppLocalizations.of(context).translate('ok'),
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.labelLarge,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeData.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.size20!,
                        vertical: MySize.size12!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MySize.size12!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, String title, IconData icon, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.size16!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: themeData.colorScheme.primary,
                size: MySize.size16!,
              ),
              SizedBox(width: MySize.size8!),
              Text(
                title,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  fontWeight: 600,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.size8!),
          child,
        ],
      ),
    );
  }

  Widget _buildActiveFiltersPreview(BuildContext context) {
    List<String> activeFilters = [];
    
    if (selectedLocation['id'] != 0) {
      activeFilters.add(selectedLocation['name']);
    }
    if (selectedCustomer['id'] != 0) {
      activeFilters.add(selectedCustomer['name']);
    }
    if (startDateRange != null && endDateRange != null) {
      activeFilters.add('${startDateRange} - ${endDateRange}');
    }
    if (selectedPaymentStatus != 'all') {
      activeFilters.add(selectedPaymentStatus.toUpperCase());
    }
    
    if (activeFilters.isEmpty) {
      return Text(
        'No filters applied',
        style: AppTheme.getTextStyle(
          themeData.textTheme.bodySmall,
          color: themeData.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }
    
    return Text(
      activeFilters.take(2).join(' • ') + (activeFilters.length > 2 ? ' +${activeFilters.length - 2}' : ''),
      style: AppTheme.getTextStyle(
        themeData.textTheme.bodySmall,
        color: themeData.colorScheme.primary,
        fontWeight: 500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}