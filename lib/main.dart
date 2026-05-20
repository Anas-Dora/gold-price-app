import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/gold_price_viewmodel.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoldPriceViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF765A00),
            surface: const Color(0xFFFFF8F1),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF765A00),
            selectionColor: Color(0xFFE3BC58),
            selectionHandleColor: Color(0xFF765A00),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
