import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const NijiPortfolioApp());
}

class NijiPortfolioApp extends StatelessWidget {
  const NijiPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niji Portfolio Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF2A2A2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4F46E5), // Indigo/Blue
          secondary: Color(0xFF22C55E), // Soft Green
          error: Color(0xFFEF4444), // Soft Red
          surface: Color(0xFF1E1E1E),
          onSurface: Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme
        ).copyWith(
          bodyMedium: GoogleFonts.inter(color: const Color(0xFFF8F9FA)),
          bodySmall: GoogleFonts.inter(color: const Color(0xFFA1A1AA)),
          titleMedium: GoogleFonts.inter(color: const Color(0xFFF8F9FA), fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.inter(color: const Color(0xFFF8F9FA), fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}
