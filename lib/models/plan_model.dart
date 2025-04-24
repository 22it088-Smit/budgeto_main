class PlanModel {
  final String id;
  final String userId;
  final String type; // emergency, car
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyAmount;
  final DateTime createdAt;
  
  PlanModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyAmount,
    required this.createdAt,
  });
  
  double get progress => currentAmount / targetAmount;
  
  int get remainingMonths {
    if (monthlyAmount <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    return (remaining / monthlyAmount).ceil();
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyAmount': monthlyAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory PlanModel.fromMap(Map<String, dynamic> map, String userId) {
    return PlanModel(
      id: map['id'] ?? '',
      userId: userId,
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyAmount: (map['monthlyAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}