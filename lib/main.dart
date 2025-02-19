import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/inventory.dart';
import 'pages/peminjaman.dart';
import 'pages/laporan.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDCC0klaOc14-9kF3oMQmeTzWjeDQIlYhw",
        authDomain: "inventory-55b29.firebaseapp.com",
        projectId: "inventory-55b29",
        storageBucket: "inventory-55b29.firebasestorage.app",
        messagingSenderId: "660960989118",
        appId: "1:660960989118:web:af922cecf6706dab40b3ef",
      ),
    );
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Inventaris',
      theme: ThemeData(
        primaryColor: const Color(0xFF14213D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14213D),
          primary: const Color(0xFF14213D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/inventory': (context) => const InventoryPage(),
        '/peminjaman': (context) => const PeminjamanPage(),
        '/laporan': (context) => const LaporanPage(),
      },
    );
  }
}
