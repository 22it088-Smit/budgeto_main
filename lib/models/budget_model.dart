class Budget {
  int needPercentage;
  int expensesPercentage;
  int savingsPercentage;
  double needAmount;
  double expensesAmount;
  double savingsAmount;
  
  Budget({
    required this.needPercentage,
    required this.expensesPercentage,
    required this.savingsPercentage,
    required this.needAmount,
    required this.expensesAmount,
    required this.savingsAmount,
  });
  
  double get totalAmount => needAmount + expensesAmount + savingsAmount;
  
  Map<String, dynamic> toMap() {
    return {
      'needPercentage': needPercentage,
      'expensesPercentage': expensesPercentage,
      'savingsPercentage': savingsPercentage,
      'needAmount': needAmount,
      'expensesAmount': expensesAmount,
      'savingsAmount': savingsAmount,
    };
  }
  
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      needPercentage: map['needPercentage'] ?? 50,
      expensesPercentage: map['expensesPercentage'] ?? 30,
      savingsPercentage: map['savingsPercentage'] ?? 20,
      needAmount: map['needAmount']?.toDouble() ?? 0.0,
      expensesAmount: map['expensesAmount']?.toDouble() ?? 0.0,
      savingsAmount: map['savingsAmount']?.toDouble() ?? 0.0,
    );
  }
}