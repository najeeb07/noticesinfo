import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noticesinfo/l10n/app_localizations.dart';
import 'package:noticesinfo/screens/home_screen.dart';
import 'package:noticesinfo/screens/categories_screen.dart';
import 'package:noticesinfo/screens/add_post_screen.dart';
import 'package:noticesinfo/screens/favorites_screen.dart';
import 'package:noticesinfo/screens/profile_screen.dart';
import 'package:noticesinfo/screens/profile_flow_screen.dart';
import 'package:noticesinfo/screens/city_search_screen.dart';
import 'package:noticesinfo/screens/settings_screen.dart';
import 'package:noticesinfo/screens/faq_screen.dart';
import 'package:noticesinfo/screens/profile_edit_screen.dart';

import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/services/location_storage_service.dart';
import 'package:noticesinfo/services/translation_service.dart';
import 'package:noticesinfo/widgets/side_menu.dart';

final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SINGLE Firebase initialization (correct)
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final String? savedLangCode = prefs.getString('language_code');

  const String googleTranslateApiKey = 'AIzaSyA4HdZiffx0XblTarBjul5nV6FAXIndhiE';

  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslationService()..initialize(googleTranslateApiKey),
      child: MyApp(
        key: myAppKey,
        initialLocale: savedLangCode != null ? Locale(savedLangCode) : null,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Locale? initialLocale;
  const MyApp({super.key, this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocationStorageService _locationStorageService = LocationStorageService();
  bool _hasCityStored = false;
  bool _isLoading = true;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _checkCityStatus();
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  Future<void> _checkCityStatus() async {
    final savedCity = await _locationStorageService.getSavedCity();
    setState(() {
      _hasCityStored = savedCity != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Notices Info',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ar'),
        Locale('te'),
        Locale('ta'),
        Locale('ml'),
        Locale('kn'),
        Locale('bn'),
        Locale('ur'),
        Locale('zh'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('si'),
        Locale('id'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: _hasCityStored ? const MainScreen() : const CitySearchScreen(),
      routes: {
        SettingsScreen.routeName: (_) => SettingsScreen(),
        FaqScreen.routeName: (_) => const FaqScreen(),
        ProfileEditScreen.routeName: (_) => const ProfileEditScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver {
  late int _selectedIndex;
  bool _isLoggedIn = false;

  final ApiService _apiService = ApiService();
  final LocationStorageService _locationStorageService =
      LocationStorageService();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkLoginStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _apiService.getToken();
    if (!mounted) return;
    setState(() => _isLoggedIn = token != null);
  }

  List<Widget> _screens() => [
        const HomeScreen(),
        const CategoriesScreen(),
        const AddPostScreen(),
        const FavoritesScreen(),
        _isLoggedIn
            ? const ProfileScreen()
            : ProfileFlowScreen(
                onLoginSuccess: () {
                  setState(() {
                    _isLoggedIn = true;
                    _selectedIndex = 4;
                  });
                },
              ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appTitle ?? 'Notices Info'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const SideMenu(),
      body: _screens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.home ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)?.categories ?? 'Categories',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: AppLocalizations.of(context)?.addPost ?? 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: AppLocalizations.of(context)?.favorites ?? 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: _isLoggedIn
                ? AppLocalizations.of(context)?.profile ?? 'Profile'
                : AppLocalizations.of(context)?.loginSignup ?? 'Login / Signup',
          ),
        ],
      ),
    );
  }
}
