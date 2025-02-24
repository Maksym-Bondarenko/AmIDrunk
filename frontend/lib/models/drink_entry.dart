class DrinkEntry {
  final String type;
  final double amount;
  final DateTime time;

  DrinkEntry({required this.type, required this.amount, required this.time});

  factory DrinkEntry.fromJson(Map<String, dynamic> json) {
    return DrinkEntry(
      type: json['type'],
      amount: json['amount'],
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'time': time.toIso8601String(),
    };
  }
}