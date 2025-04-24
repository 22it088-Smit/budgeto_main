class StockModel {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change;
  final String riskLevel; // Low, Medium, High
  
  StockModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.riskLevel,
  });
  
  bool get isPositive => change >= 0;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'riskLevel': riskLevel,
    };
  }
  
  factory StockModel.fromMap(Map<String, dynamic> map, String docId) {
    return StockModel(
      id: docId,
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      change: map['change']?.toDouble() ?? 0.0,
      riskLevel: map['riskLevel'] ?? 'Medium',
    );
  }
}