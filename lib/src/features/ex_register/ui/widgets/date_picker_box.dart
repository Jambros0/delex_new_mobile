// ignore_for_file: must_be_immutable

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/dateFilterModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class YearToDateBox extends StatefulWidget {
  bool customRangeFlag;
  final double height;
  final double width;
  final Map<String, dynamic>? dateRange;
  final DateFilter? selectedDateFilter;
  final String type;
  final void Function(
          String?, DateTime?, DateTime?, bool isReset, String isSelectedtype)?
      onDateRangeSelected;
  final Function()? onCustomRangeSelected;
  final Function()? onRangeSelected;
  final String dateType;
  YearToDateBox({
    super.key,
    required this.customRangeFlag,
    required this.height,
    required this.width,
    this.onDateRangeSelected,
    this.dateRange,
    this.selectedDateFilter,
    required this.type,
    this.onCustomRangeSelected,
    this.onRangeSelected,
    required this.dateType,
  });

  @override
  State<YearToDateBox> createState() => _YearToDateBoxState();
}

class _YearToDateBoxState extends State<YearToDateBox> {
  @override
  void initState() {
    super.initState();
  }

  void _showDialog(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double buttonWidth = widget.customRangeFlag
        ? isPortrait
            ? screenWidth * 0.45
            : screenWidth * 0.48
        : isPortrait
            ? screenWidth * 0.45
            : screenWidth * 0.22;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x14000000),
      barrierLabel: 'Dismiss',
      pageBuilder: (context, anim1, anim2) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double dialogWidth =
                isPortrait ? screenWidth * 0.4 : screenWidth * 0.28;
            final double dialogHeight =
                isPortrait ? screenHeight * 0.4 : screenHeight * 0.795;

            final double offsetX = widget.customRangeFlag
                ? widget.type == "asset"
                    ? (constraints.maxWidth - dialogWidth) * 0.534
                    : (constraints.maxWidth - dialogWidth) * 0.67
                : widget.type == "asset"
                    ? (constraints.maxWidth - dialogWidth) * 0.895
                    : (constraints.maxWidth - dialogWidth) * 1.032;
            final double offsetY = widget.type == "asset"
                ? (constraints.maxHeight - dialogHeight) * 1.30
                : (constraints.maxHeight - dialogHeight) * 1.23;
            return Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD0D3D8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: buttonWidth,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomDatePicker(
                            customRangeFlag: widget.customRangeFlag,
                            selectedDateFilter: widget.selectedDateFilter,
                            onDateRangeSelected:
                                (type, range, isReset, isSelectedtype) {
                              if (widget.onDateRangeSelected != null) {
                                widget.onDateRangeSelected!(type, range?.start,
                                    range?.end, isReset, isSelectedtype);
                              }
                              Navigator.of(context).pop();
                            },
                            onCustomRangeSelected:
                                (type, range, isReset, isSelectedtype) {
                              setState(() {
                                widget.customRangeFlag = true;
                                widget.onDateRangeSelected!(type, range?.start,
                                    range?.end, isReset, isSelectedtype);
                                Navigator.of(context).pop();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _showDialog(context);
                                });
                              });
                            })
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _showDialog(context),
      child: Container(
        width: widget.width,
        height: (48 / screenHeight) * screenHeight,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.005,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFB3B3B3),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                widget.dateType == "" ? 'Year to Date' : widget.dateType,
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF212121),
                    height: 24 / 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF3B475B),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDatePicker extends StatefulWidget {
  final DateFilter? selectedDateFilter;
  final void Function(
          String?, DateTimeRange?, bool clickType, String isSelectedtype)
      onDateRangeSelected;
  final void Function(
          String?, DateTimeRange?, bool clickType, String isSelectedtype)
      onCustomRangeSelected;
  final Function()? onRangeSelected;
  bool customRangeFlag;
  CustomDatePicker(
      {super.key,
      required this.onDateRangeSelected,
      this.selectedDateFilter,
      required this.onCustomRangeSelected,
      this.onRangeSelected,
      required this.customRangeFlag});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String type = "";
  TextEditingController customDateController = TextEditingController();
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _fromDate = widget.selectedDateFilter?.fromDate;
      _toDate = widget.selectedDateFilter?.toDate;
      _rangeDatePickerValueWithDefaultValue = [
        widget.selectedDateFilter?.fromDate,
        widget.selectedDateFilter?.toDate
      ];
    });
  }

  void _selectDateRange(DateTimeRange range) {
    setState(() {
      _fromDate = range.start;
      _toDate = range.end;
    });
    widget.onDateRangeSelected(type, range, false, type);
  }

  void _setPresetRange(PresetRange range) {
    type = '';
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (range) {
      case PresetRange.today:
        start = now;
        end = now;
        type = "Today";
        break;
      case PresetRange.yesterday:
        start = now.subtract(const Duration(days: 1));
        end = now.subtract(const Duration(days: 1));
        type = "Yesterday";
        break;
      case PresetRange.lastWeek:
        start = now.subtract(Duration(days: now.weekday + 6));
        end = now.subtract(Duration(days: now.weekday - 1));
        type = "Last Week";
        break;
      case PresetRange.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        type = "Last Month";
        break;
      case PresetRange.lastYear:
        start = DateTime(now.year, 1, 1);
        end = now;
        type = "Last Year";
        break;
    }

    _selectDateRange(DateTimeRange(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Row(children: [
      widget.customRangeFlag
          ? SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.54,
              child: Column(
                children: [
                  CalendarDatePicker2(
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      controlsHeight: 40,
                      buttonPadding: EdgeInsets.zero,
                      animateToDisplayedMonthDate: true,
                      weekdayLabels: [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat'
                      ],
                      centerAlignModePicker: true,
                      useAbbrLabelForMonthModePicker: true,
                      daySplashColor: Colors.lightBlue,
                      rangeBidirectional: true,
                      dayBuilder: ({
                        required date,
                        textStyle,
                        decoration,
                        isSelected,
                        isDisabled,
                        isToday,
                      }) {
                        Widget? dayWidget;
                        dayWidget = isSelected!
                            ? Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  decoration: decoration,
                                  child: Center(
                                    child: Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        Text(
                                          MaterialLocalizations.of(context)
                                              .formatDecimal(date.day),
                                          style: textStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: decoration,
                                padding: const EdgeInsets.all(3),
                                child: Center(
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Text(
                                        MaterialLocalizations.of(context)
                                            .formatDecimal(date.day),
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              );

                        return dayWidget;
                      },
                      selectedRangeDayTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1B2029),
                          fontWeight: FontWeight.w500),
                      selectedRangeHighlightBuilder: ({
                        DateTime? dayToBuild,
                        bool isStartDate = false,
                        bool isEndDate = false,
                      }) {
                        return Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: isStartDate || isEndDate
                                ? Colors.blue.shade100
                                : Colors.blue.shade100,
                            borderRadius: isStartDate
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8))
                                : isEndDate
                                    ? const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8))
                                    : BorderRadius.zero,
                          ),
                          child: Center(
                            child: Text(
                              '${dayToBuild!.day}',
                              style: TextStyle(
                                color: isStartDate || isEndDate
                                    ? Colors.white
                                    : Colors.transparent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                      dayMaxWidth: 38,
                      selectedRangeHighlightColor: Colors.blue.shade100,
                      hideMonthPickerDividers: false,
                      calendarType: CalendarDatePicker2Type.range,
                      selectedDayHighlightColor: const Color(0xFF002B5C),
                      dayTextStyle: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF1B2029),
                          fontWeight: FontWeight.w500),
                      weekdayLabelTextStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF848B98),
                          height: 16 / 12),
                      controlsTextStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF002B5C),
                          height: 20 / 14),
                      selectedDayTextStyle:
                          GoogleFonts.inter(fontSize: 16, color: Colors.white),
                      nextMonthIcon: const Icon(
                        size: 20,
                        Icons.arrow_forward_ios,
                        color: Color(0xFF3B475B),
                      ),
                      dayBorderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                      lastMonthIcon: const Icon(Icons.arrow_back_ios,
                          size: 20, color: Color(0xFF3B475B)),
                    ),
                    value: _rangeDatePickerValueWithDefaultValue,
                    onValueChanged: (dates) {
                      setState(() {
                        _rangeDatePickerValueWithDefaultValue = dates;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            label: const Text('Set Date',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17)),
                            onPressed: () {
                              if (_rangeDatePickerValueWithDefaultValue.isEmpty) return;
                              setState(() {
                                _fromDate = _rangeDatePickerValueWithDefaultValue[0];
                                _toDate = _rangeDatePickerValueWithDefaultValue.length > 1
                                    ? _rangeDatePickerValueWithDefaultValue[1]
                                    : _rangeDatePickerValueWithDefaultValue[0];
                                type = "Custom Range";
                              });
                              widget.onDateRangeSelected(
                                  type,
                                  DateTimeRange(
                                      start: _fromDate!, end: _toDate!),
                                  false,
                                  type);

                              // Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // Border radius
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _rangeDatePickerValueWithDefaultValue = [];
                                  widget.customRangeFlag = false;
                                });
                                widget.onDateRangeSelected(
                                    type,
                                    DateTimeRange(
                                        start: DateTime.now(),
                                        end: DateTime.now()),
                                    true,
                                    type);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF002B5C),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'lib/src/features/ex_register/assets/refresh.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ))
          : const SizedBox(),
      widget.customRangeFlag
          ? Container(
              width: 0.3,
              height: screenHeight * 0.55,
              color: Colors.grey,
            )
          : const SizedBox(),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: screenWidth * 0.20,
          height: screenHeight * 0.54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {},
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onDateRangeSelected(
                      "Year to Date",
                      DateTimeRange(
                        start: DateTime(2024, 1, 1),
                        end: DateTime.now(),
                      ),
                      false,
                      "Year to Date"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: widget.selectedDateFilter?.filterType ==
                              "Year to Date"
                          ? const Color(0xFFEDF3F8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Year to Date",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    height: 24 / 17),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              widget.selectedDateFilter?.filterType ==
                                      "Year to Date"
                                  ? dateWidget(
                                      screenHeight, widget.selectedDateFilter)
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildOption(
                context: context,
                option: "Today",
                fontSize: screenHeight * 0.022,
                isSelected: widget.selectedDateFilter?.filterType == "Today",
                subtitle: widget.selectedDateFilter?.filterType == "Today"
                    ? dateWidget(screenHeight, widget.selectedDateFilter)
                    : null,
                onTap: () {
                  _setPresetRange(PresetRange.today);
                },
                onRangeTap: () => widget.onRangeSelected,
              ),
              _buildOption(
                context: context,
                option: "Yesterday",
                fontSize: screenHeight * 0.022,
                isSelected:
                    widget.selectedDateFilter?.filterType == "Yesterday",
                subtitle: widget.selectedDateFilter?.filterType == "Yesterday"
                    ? dateWidget(screenHeight, widget.selectedDateFilter)
                    : null,
                onTap: () {
                  _setPresetRange(PresetRange.yesterday);
                },
                onRangeTap: () => widget.onRangeSelected,
              ),
              _buildOption(
                context: context,
                option: "Last Week",
                fontSize: screenHeight * 0.022,
                isSelected:
                    widget.selectedDateFilter?.filterType == "Last Week",
                subtitle: widget.selectedDateFilter?.filterType == "Last Week"
                    ? dateWidget(screenHeight, widget.selectedDateFilter)
                    : null,
                onTap: () {
                  _setPresetRange(PresetRange.lastWeek);
                },
                onRangeTap: () => widget.onRangeSelected,
              ),
              _buildOption(
                context: context,
                option: "Last Month",
                fontSize: screenHeight * 0.022,
                isSelected:
                    widget.selectedDateFilter?.filterType == "Last Month",
                subtitle: widget.selectedDateFilter?.filterType == "Last Month"
                    ? dateWidget(screenHeight, widget.selectedDateFilter)
                    : null,
                onTap: () {
                  _setPresetRange(PresetRange.lastMonth);
                },
                onRangeTap: () => widget.onRangeSelected,
              ),
              _buildOption(
                context: context,
                option: "Last Year",
                fontSize: screenHeight * 0.022,
                isSelected:
                    widget.selectedDateFilter?.filterType == "Last Year",
                subtitle: widget.selectedDateFilter?.filterType == "Last Year"
                    ? dateWidget(screenHeight, widget.selectedDateFilter)
                    : null,
                onTap: () {
                  _setPresetRange(PresetRange.lastYear);
                },
                onRangeTap: () => widget.onRangeSelected,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onRangeSelected,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      // if (widget.selectedDateFilter?.filterType.toString() !=
                      //     "Custom Range") {
                      //   type =
                      //       (widget.selectedDateFilter?.filterType.toString() !=
                      //               "Custom Range"
                      //           ? "Custom Range"
                      //           : widget.selectedDateFilter?.filterType
                      //               .toString())!;
                      //   widget.onCustomRangeSelected(
                      //       type,
                      //       null,
                      //       // DateTimeRange(
                      //       //   start: type == "Custom Range"
                      //       //       ? DateTime.now()
                      //       //       : _fromDate ?? DateTime.now(),
                      //       //   end: type == "Custom Range"
                      //       //       ? DateTime.now()
                      //       //       : _toDate ?? DateTime.now(),
                      //       // ),
                      //       false,
                      //       type);
                      // } else {
                      type = (widget.selectedDateFilter?.filterType
                                  .toString() !=
                              "Custom Range"
                          ? "Custom Range"
                          : widget.selectedDateFilter?.filterType.toString())!;
                      widget.onCustomRangeSelected(
                          type,
                          // null,
                          DateTimeRange(
                            start: type == "Custom Range"
                                ? DateTime.now()
                                : _fromDate ?? DateTime.now(),
                            end: type == "Custom Range"
                                ? DateTime.now()
                                : _toDate ?? DateTime.now(),
                          ),
                          false,
                          type);
                      // }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: widget.selectedDateFilter?.filterType ==
                              "Custom Range"
                          ? const Color(0xFFEDF3F8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Custom Range",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    height: 24 / 17),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              widget.selectedDateFilter?.filterType ==
                                      "Custom Range"
                                  ? dateWidget(
                                      screenHeight, widget.selectedDateFilter)
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          )),
    ]);
  }

  Widget _buildOption({
    required BuildContext context,
    required String option,
    required double fontSize,
    required bool isSelected,
    required Widget? subtitle,
    required GestureTapCallback? onTap,
    required GestureTapCallback? onRangeTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onRangeTap,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEDF3F8) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 24 / 17),
                    ),
                    const SizedBox(height: 2),
                    subtitle ?? const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(DateTime? date) {
  String? day = date?.day.toString().padLeft(2, '0');
  String? month = date?.month.toString().padLeft(2, '0');
  String? year = date?.year.toString();
  return '$day/$month/$year';
}

Widget dateWidget(screenHeight, selectedDateFilter) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      "${formatDate(selectedDateFilter!.fromDate)} - ${formatDate(selectedDateFilter!.toDate)}",
      style: GoogleFonts.inter(
        fontSize: screenHeight * 0.017,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

enum PresetRange {
  today,
  yesterday,
  lastWeek,
  lastMonth,
  lastYear,
}
