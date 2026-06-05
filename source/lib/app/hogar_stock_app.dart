import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

class HogarStockApp extends StatelessWidget {
  const HogarStockApp({
    super.key,
    required this.categoryService,
    required this.productService,
  });

  final CategoryService categoryService;
  final ProductService productService;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F80ED);
    const surface = Color(0xFF101820);
    const card = Color(0xFF172331);
    const border = Color(0xFF2B3948);

    return MaterialApp(
      title: 'HogarStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF142235),
          foregroundColor: Color(0xFFEAF2FF),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: card,
        ),
      ),
      home: DashboardScreen(
        categoryService: categoryService,
        productService: productService,
      ),
    );
  }
}
