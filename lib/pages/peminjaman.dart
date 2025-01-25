import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '/models/inventory_model.dart';
import '/models/peminjaman_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Peminjaman> peminjamanList = [];
  List<User> userList = [];
  List<Inventory> inventoryList = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Form controllers
  late TextEditingController _notesController;
  DateTime _borrowDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedUserId;
  String? _selectedInventoryId;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load users
      final QuerySnapshot usersSnapshot =
          await _firestore.collection('users').get();
      print('Loading users: ${usersSnapshot.docs.length} documents found');

      List<User> users =
          usersSnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      print(users);
      // Load inventory
      final QuerySnapshot inventorySnapshot =
          await _firestore.collection('inventory').get();
      print(inventorySnapshot);
      print(
          'Loading inventory: ${inventorySnapshot.docs.length} documents found');

      List<Inventory> inventory = inventorySnapshot.docs
          .map((doc) => Inventory.fromFirestore(doc))
          .toList();
      print(inventory);
      // Load peminjaman with related data
      final QuerySnapshot peminjamanSnapshot =
          await _firestore.collection('peminjaman').get();

      List<Peminjaman> peminjaman = await Future.wait(
        peminjamanSnapshot.docs.map((doc) async {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Safe conversion of dates with null checking
          DateTime? borrowDate;
          DateTime? returnDate;

          // Handle borrowDate
          if (data['borrowDate'] is Timestamp) {
            borrowDate = (data['borrowDate'] as Timestamp).toDate();
          } else if (data['borrowDate'] is String) {
            borrowDate = DateTime.parse(data['borrowDate']);
          } else {
            borrowDate = DateTime.now(); // Default value
          }

          // Handle returnDate
          if (data['returnDate'] is Timestamp) {
            returnDate = (data['returnDate'] as Timestamp).toDate();
          } else if (data['returnDate'] is String) {
            returnDate = DateTime.parse(data['returnDate']);
          } else {
            returnDate =
                DateTime.now().add(const Duration(days: 7)); // Default value
          }

          // Get user data
          User? user;
          if (data['userId'] != null) {
            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(data['userId']).get();
            if (userDoc.exists) {
              user = User.fromFirestore(userDoc);
            }
          }

          // Get inventory data
          Inventory? inventory;
          if (data['inventoryId'] != null) {
            DocumentSnapshot inventoryDoc = await _firestore
                .collection('inventory')
                .doc(data['inventoryId'])
                .get();
            if (inventoryDoc.exists) {
              inventory = Inventory.fromFirestore(inventoryDoc);
            }
          }

          return Peminjaman(
            id: doc.id,
            userId: data['userId'] ?? '',
            inventoryId: data['inventoryId'] ?? '',
            borrowDate: borrowDate,
            returnDate: returnDate,
            status: data['status'] ?? 'unknown',
            notes: data['notes'],
            user: user,
            inventory: inventory,
          );
        }),
      );

      // Update state
      setState(() {
        userList = users;
        inventoryList = inventory;
        peminjamanList = peminjaman;
        _isLoading = false;
      });

      print(
          'Successfully loaded: ${users.length} users, ${inventory.length} inventory items, ${peminjaman.length} peminjaman records');
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPeminjaman() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Ensure we're using Timestamp for dates
        final newPeminjaman = {
          'userId': _selectedUserId,
          'inventoryId': _selectedInventoryId,
          'borrowDate': Timestamp.fromDate(_borrowDate),
          'returnDate': Timestamp.fromDate(_returnDate),
          'status': 'dipinjam',
          'notes': _notesController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add to Firestore
        final docRef =
            await _firestore.collection('peminjaman').add(newPeminjaman);
        print('Created new peminjaman with ID: ${docRef.id}');

        // Refresh data
        await _loadData();

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error submitting peminjaman: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddPeminjamanModal() async {
    _resetForm();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Peminjaman Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    decoration: const InputDecoration(labelText: 'Peminjam'),
                    items: userList.map((User user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text(user.fullName),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih peminjam';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Inventory dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedInventoryId,
                    decoration: const InputDecoration(labelText: 'Barang'),
                    items: inventoryList.map((Inventory item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedInventoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih barang';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Borrow date picker
                  ListTile(
                    title: const Text('Tanggal Pinjam'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(_borrowDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _borrowDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _borrowDate = picked;
                        });
                      }
                    },
                  ),

                  // Return date picker
                  ListTile(
                    title: const Text('Tanggal Kembali'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(_returnDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _returnDate,
                        firstDate: _borrowDate,
                        lastDate: _borrowDate.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _returnDate = picked;
                        });
                      }
                    },
                  ),

                  // Notes text field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      hintText: 'Tambahkan catatan jika diperlukan',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitPeminjaman();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14213D),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    _selectedUserId = null;
    _selectedInventoryId = null;
    _borrowDate = DateTime.now();
    _returnDate = DateTime.now().add(const Duration(days: 7));
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Inventaris'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Profile action
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF14213D),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF14213D)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Admin Name',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'admin@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventaris'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Peminjaman'),
              selected: true,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/peminjaman');
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/laporan');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peminjaman Barang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddPeminjamanModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14213D),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Pinjam',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari peminjaman...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: peminjamanList.length,
                itemBuilder: (context, index) {
                  final peminjaman = peminjamanList[index];
                  return _buildLoanCard(
                    peminjaman.user?.fullName ?? 'Unknown',
                    peminjaman.inventory?.name ?? 'Unknown Item',
                    DateFormat('yyyy-MM-dd').format(peminjaman.borrowDate),
                    DateFormat('yyyy-MM-dd').format(peminjaman.returnDate),
                    peminjaman.status,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(
    String name,
    String item,
    String borrowDate,
    String returnDate,
    String status,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            Text(
              item,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text('Tanggal Pinjam: $borrowDate'),
            Text('Tanggal Kembali: $returnDate'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Detail action
                    },
                    child: const Text('Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'dipinjam')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Return action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14213D),
                      ),
                      child: const Text(
                        'Kembalikan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'dipinjam':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue;
        break;
      case 'dikembalikan':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
