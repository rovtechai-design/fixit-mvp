class Customer {
  final String id;
  final String name;
  final String phone;
  final String flat;
  final String building;
  final String area;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.flat,
    required this.building,
    required this.area,
    required this.createdAt,
  });

  String get address => '$flat, $building, $area';

  Customer copyWith({String? name, String? flat, String? building, String? area}) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone,
      flat: flat ?? this.flat,
      building: building ?? this.building,
      area: area ?? this.area,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'flat': flat,
        'building': building,
        'area': area,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        flat: json['flat'] as String,
        building: json['building'] as String,
        area: json['area'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
