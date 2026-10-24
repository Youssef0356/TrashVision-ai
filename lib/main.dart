import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/detector_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the on-device AI detector service
  await DetectorService.instance.initialize();

  runApp(const TrashVisionApp());
}

class TrashVisionApp extends StatelessWidget {
  const TrashVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrashVision AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111714),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE85D04),
          secondary: Color(0xFF55A630),
          surface: Color(0xFF19231D),
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
