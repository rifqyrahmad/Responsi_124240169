import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShoppingHubApp());
}

class ShoppingHubApp extends StatelessWidget {
  const ShoppingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'ShoppingHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark slate blue
          primaryColor: const Color.fromARGB(255, 66, 198, 51), // Indigo
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color.fromARGB(255, 6, 241, 68),
            secondary: Color.fromARGB(255, 20, 154, 109),
            surface: Color(0xFF1E293B),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

// Pemeriksaan sesi login pengguna
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _authCheck;

  @override
  void initState() {
    super.initState();
    _authCheck = context.read<AuthProvider>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 74, 215, 81)),
            ),
          );
        }

        final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
        return isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
