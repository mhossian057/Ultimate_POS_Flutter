import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../../helpers/AppTheme.dart';
import '../../../helpers/SizeConfig.dart';
import '../../../locale/MyLocalizations.dart';

class DateRangePickerScreen extends StatefulWidget {
  final String? startDateRange;
  final String? endDateRange;
  final ThemeData themeData;

  const DateRangePickerScreen({
    Key? key,
    required this.startDateRange,
    required this.endDateRange,
    required this.themeData,
  }) : super(key: key);

  @override
  _DateRangePickerScreenState createState() => _DateRangePickerScreenState();
}

class _DateRangePickerScreenState extends State<DateRangePickerScreen> {
  String? startDateRange;
  String? endDateRange;

  @override
  void initState() {
    super.initState();
    startDateRange = widget.startDateRange;
    endDateRange = widget.endDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('select_range')),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                firstDayOfWeek: 1,
                selectedDayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                selectedDayHighlightColor: widget.themeData.colorScheme.primary,
                calendarViewMode: CalendarDatePicker2Mode.year,
              ),
              value: [
                startDateRange != null ? DateTime.tryParse(startDateRange!) : null,
                endDateRange != null ? DateTime.tryParse(endDateRange!) : null,
              ],
              onValueChanged: (dates) {
                if (dates.isNotEmpty && dates[0] != null) {
                  setState(() {
                    startDateRange = DateFormat('yyyy-MM-dd')
                        .format(dates[0]!)
                        .toString();
                  });
                }
                if (dates.length > 1 && dates[1] != null) {
                  setState(() {
                    endDateRange = DateFormat('yyyy-MM-dd')
                        .format(dates[1]!)
                        .toString();
                  });
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: MySize.size30!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.size20!),
                      side: BorderSide(color: widget.themeData.colorScheme.primary)),
                  foregroundColor: widget.themeData.colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    startDateRange = null;
                    endDateRange = null;
                  });
                  Navigator.pop(context, {
                    'startDate': null,
                    'endDate': null,
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('reset'),
                  style: AppTheme.getTextStyle(widget.themeData.textTheme.headlineSmall,
                      color: widget.themeData.colorScheme.onPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.size20!),
                      side: BorderSide(color: widget.themeData.colorScheme.primary)),
                  foregroundColor: widget.themeData.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'startDate': startDateRange,
                    'endDate': endDateRange,
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('ok'),
                  style: AppTheme.getTextStyle(widget.themeData.textTheme.headlineSmall,
                      color: widget.themeData.colorScheme.onPrimary),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}