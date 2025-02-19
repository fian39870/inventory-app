import 'user_model.dart';
import 'inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Peminjaman {
  final String id;
  final String userId;
  final String inventoryId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String status;
  final String notes;
  final User? user;
  final Inventory? inventory;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.inventoryId,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    required this.notes,
    this.user,
    this.inventory,
  });

  // Factory constructor jika diperlukan
  factory Peminjaman.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Peminjaman(
      id: doc.id,
      userId: data['userId'] ?? '',
      inventoryId: data['inventoryId'] ?? '',
      borrowDate:
          (data['borrowDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      status: data['status'] ?? 'unknown',
      notes: data['notes'] ?? '',
      // user dan inventory akan diset terpisah
    );
  }
}
