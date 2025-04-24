class PayeeModel {
  final String id;
  final String userId;
  final String name;
  final String accountNumber;
  final String category; // Need, Expenses
  
  PayeeModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountNumber,
    required this.category,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'accountNumber': accountNumber,
      'category': category,
    };
  }
  
  factory PayeeModel.fromMap(Map<String, dynamic> map, String userId) {
    return PayeeModel(
      id: map['id'] ?? '',
      userId: userId,
      name: map['name'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      category: map['category'] ?? '',
    );
  }
}