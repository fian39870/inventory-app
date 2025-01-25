import 'user_model.dart';
import 'inventory_model.dart';

class Peminjaman {
  final String? id;
  final String userId;
  final String inventoryId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String status; // dipinjam, dikembalikan
  final String? notes;
  final User? user; // Relasi ke model User
  final Inventory? inventory; // Relasi ke model Inventory

  Peminjaman({
    this.id,
    required this.userId,
    required this.inventoryId,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    this.notes,
    this.user,
    this.inventory,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      userId: json['userId'],
      inventoryId: json['inventoryId'],
      borrowDate: DateTime.parse(json['borrowDate']),
      returnDate: DateTime.parse(json['returnDate']),
      status: json['status'],
      notes: json['notes'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      inventory: json['inventory'] != null
          ? Inventory.fromJson(json['inventory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'inventoryId': inventoryId,
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'user': user?.toJson(),
      'inventory': inventory?.toJson(),
    };
  }
}
