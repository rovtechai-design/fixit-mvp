import 'trade.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String phone;
  final Trade trade;
  final DateTime createdAt;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.trade,
    required this.createdAt,
  });

  ServiceProvider copyWith({String? name, Trade? trade}) {
    return ServiceProvider(
      id: id,
      name: name ?? this.name,
      phone: phone,
      trade: trade ?? this.trade,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'trade': trade.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceProvider.fromJson(Map<String, dynamic> json) => ServiceProvider(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        trade: TradeLabel.fromName(json['trade'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
