import 'package:flutter/material.dart';

import 'screens/disease_guide_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/scanner_screen.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  await LanguageService.instance.init();
  await TtsService.init();
  runApp(const CoffeeDiseaseApp());
}

class CoffeeDiseaseApp extends StatefulWidget {
  const CoffeeDiseaseApp({super.key});

  @override
  State<CoffeeDiseaseApp> createState() => _CoffeeDiseaseAppState();
}

class _CoffeeDiseaseAppState extends State<CoffeeDiseaseApp> {
  @override
  void initState() {
    super.initState();
    LanguageService.instance.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Leaf Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5E3A),
          primary: const Color(0xFF1E5E3A),
          surface: const Color(0xFFF9FBF9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E5E3A),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: AuthService.isLoggedIn
          ? const MainNavigationScreen()
          : LoginScreen(
              onLoginSuccess: () {
                setState(() {});
              },
            ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final LanguageService _lang = LanguageService.instance;

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_lang.t('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.languageNames.entries.map((entry) {
            final isSelected = _lang.currentLanguage == entry.key;
            return ListTile(
              title: Text(
                entry.value,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1E5E3A) : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF1E5E3A))
                  : null,
              onTap: () {
                _lang.setLanguage(entry.key);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('መውጣት (Logout)'),
        content: const Text('ከአካውንትዎ መውጣት ይፈልጋሉ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('አይ (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pop(ctx);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      onLoginSuccess: () {
                        setState(() {});
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('ውጣ (Logout)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      ScannerScreen(),
      HistoryScreen(),
      DiseaseGuideScreen(),
    ];

    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _lang.t('app_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user != null ? '👤 ${user.name} (${user.farmLocation})' : _lang.t('app_subtitle'),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: _lang.t('select_language'),
            onPressed: _showLanguageDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt_rounded),
            label: _lang.t('tab_scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: _lang.t('tab_history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: _lang.t('tab_guide'),
          ),
        ],
      ),
    );
  }
}
