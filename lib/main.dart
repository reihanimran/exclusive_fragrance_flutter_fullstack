// ignore_for_file: prefer_const_constructors
import 'package:exclusive_fragrance/screens/login_and_register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exclusive_fragrance/provider/network_provider.dart';
import 'package:exclusive_fragrance/provider/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF5D57A),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        fontFamily: 'Open Sans',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5D57A),
            foregroundColor: const Color(0xFF151E25),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5D57A),
          titleTextStyle: TextStyle(
            color: const Color(0xFF151E25),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: const Color(0xFF151E25)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFFF5D57A),
          selectedItemColor: const Color(0xFF151E25),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 5,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: const Color(0xFF151E25),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: const Color(0xFF151E25),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          displayLarge: TextStyle(
            color: const Color(0xFF151E25),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(
            color: Colors.black54,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFF5D57A),
        scaffoldBackgroundColor: const Color(0xFF151E25),
        fontFamily: 'Open Sans',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5D57A),
            foregroundColor: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E2832),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E2832),
          selectedItemColor: const Color(0xFFF5D57A),
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 5,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          displayLarge: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
          fillColor: const Color(0xFF1E2832),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(
            color: Colors.white70,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: LoginRegisterScreen(),
    );
  }
}
