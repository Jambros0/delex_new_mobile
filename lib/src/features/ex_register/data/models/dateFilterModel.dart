class DateFilter {
  final String? filterType;
  final DateTime? fromDate;
  final DateTime? toDate;

  DateFilter({
    this.filterType,
    this.fromDate,
    this.toDate,
  });

  // Factory method to create an instance from JSON
  factory DateFilter.fromJson(Map<String, dynamic> json) {
    return DateFilter(
      filterType: json['filterType'] ?? '',
      fromDate: json['fromDate'] != null ? DateTime.parse(json['fromDate']) : null,
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'filterType': filterType,
      'fromDate': fromDate?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'toDate': toDate?.toIso8601String(),     // Convert DateTime to ISO 8601 string
    };
  }
}