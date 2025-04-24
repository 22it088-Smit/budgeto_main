class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String type; // income, expense, transfer, investment, plan
  
  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
  
  factory TransactionModel.fromMap(Map<String, dynamic> map, String userId) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: userId,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      type: map['type'] ?? '',
    );
  }
}