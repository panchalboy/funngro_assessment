class EarningsListModel {
  final String? id;
  final String? title;
  final String? company;
  final int? payout;

  EarningsListModel({this.id, this.title, this.company, this.payout});
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
