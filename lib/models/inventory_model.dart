import 'package:cloud_firestore/cloud_firestore.dart';

class Inventory {
  final String? id;
  final String name;
  final String code;
  final String category;
  final int stock;
  final String condition;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Inventory({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.stock,
    required this.condition,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firestore DocumentSnapshot
  factory Inventory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Inventory(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      condition: data['condition'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create from JSON (for other data sources)
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      condition: json['condition'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'category': category,
      'stock': stock,
      'condition': condition,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert to JSON for other purposes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'stock': stock,
      'condition': condition,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of Inventory with modified fields
  Inventory copyWith({
    String? id,
    String? name,
    String? code,
    String? category,
    int? stock,
    String? condition,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Compare two Inventory objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Inventory &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.category == category &&
        other.stock == stock &&
        other.condition == condition &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        code.hashCode ^
        category.hashCode ^
        stock.hashCode ^
        condition.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
