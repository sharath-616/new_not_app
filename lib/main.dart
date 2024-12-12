import 'package:flutter/material.dart';
import 'package:new_not_app/Screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//Initial Theem mode set up

  ThemeMode _themeMode = ThemeMode.light;

// Theem preference handile
  Future<void> _loadTheemPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDarkMode = pref.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

// set toggler btn

  Future<void> _togglerTheem(bool isDarkMode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      pref.setBool('isDarkMode', isDarkMode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheemPreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: HomePage(
        onThemeChanged: _togglerTheem,
      ),
    );
  }
}
