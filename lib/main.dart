import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noticesinfo/screens/home_screen.dart';
import 'package:noticesinfo/screens/categories_screen.dart';
import 'package:noticesinfo/screens/add_post_screen.dart';
import 'package:noticesinfo/screens/favorites_screen.dart';
import 'package:noticesinfo/screens/login_screen.dart'; // Import LoginScreen
import 'package:noticesinfo/screens/signup_screen.dart'; // Import SignupScreen
import 'package:noticesinfo/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:noticesinfo/screens/profile_flow_screen.dart';
import 'package:noticesinfo/services/api_service.dart'; // Import ProfileFlowScreen
import 'package:noticesinfo/widgets/side_menu.dart'; // Import SideMenu
import 'package:noticesinfo/screens/settings_screen.dart'; // Import SettingsScreen
import 'package:noticesinfo/screens/faq_screen.dart'; // Import FaqScreen
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:noticesinfo/services/location_service.dart'; // Import LocationService
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this import
import 'package:noticesinfo/l10n/app_localizations.dart'; // Add this import
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import flutter_typeahead for city input
import 'package:geocoding/geocoding.dart'; // Import geocoding for city input
import 'package:geolocator/geolocator.dart'; // Import geolocator for openLocationSettings
import 'package:noticesinfo/screens/city_search_screen.dart'; // Import CitySearchScreen
import 'package:noticesinfo/services/location_storage_service.dart'; // Import LocationStorageService
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:provider/provider.dart'; // Import provider
import 'package:noticesinfo/services/translation_service.dart'; // Import TranslationService
import 'package:noticesinfo/screens/profile_edit_screen.dart'; // Import ProfileEditScreen

final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling for iOS
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue app execution even if Firebase fails
    // This allows the app to work on iOS without GoogleService-Info.plist
  }
  
  final prefs = await SharedPreferences.getInstance();
  final String? savedLangCode = prefs.getString('language_code');
  Locale? initialLocale;
  if (savedLangCode != null) {
    initialLocale = Locale(savedLangCode);
  }

  // User will provide the API key
  // For now, let's assume the API key is passed here.
  // In a real application, you might get this from an environment variable or a configuration file.
  const String googleTranslateApiKey = 'AIzaSyA4HdZiffx0XblTarBjul5nV6FAXIndhiE';

  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslationService()..initialize(googleTranslateApiKey),
      child: MyApp(key: myAppKey, initialLocale: initialLocale),
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
  Locale? _locale; // Add this line

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale; // Add this line
    _checkCityStatus();
  }

  void setLocale(Locale newLocale) { // Add this method
    setState(() { // Add this line
      _locale = newLocale; // Add this line
    }); // Add this line
  } // Add this line

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
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Notices Info', // Modify this line
      debugShowCheckedModeBanner: false,
      locale: _locale, // Add this line
      localizationsDelegates: const [ // Add this section
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate, // Add this line
        GlobalWidgetsLocalizations.delegate, // Add this line
        GlobalCupertinoLocalizations.delegate, // Add this line
      ], // Add this line
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('ar', ''), // Arabic
        Locale('te', ''), // Telugu
        Locale('ta', ''), // Tamil
        Locale('ml', ''), // Malayalam
        Locale('kn', ''), // Kannada
        Locale('bn', ''), // Bangla
        Locale('ur', ''), // Urdu
        Locale('zh', ''), // Chinese
        Locale('de', ''), // German
        Locale('fr', ''), // French
        Locale('es', ''), // Spanish
        Locale('si', ''), // Sinhalese
        Locale('id', ''), // Indonesian
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _hasCityStored ? MainScreen() : const CitySearchScreen(), // Removed const
      routes: {
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        FaqScreen.routeName: (ctx) => const FaqScreen(),
        ProfileEditScreen.routeName: (ctx) => const ProfileEditScreen(), // Add ProfileEditScreen route
        '/home': (ctx) => MainScreen(), // Removed const
        '/citySearch': (ctx) => const CitySearchScreen(), // Define a route for CitySearchScreen
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key); // Changed super.key to Key? key

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _selectedIndex;
  bool _isLoggedIn = false; // New state to track login status
  String? _currentCity; // New state to store current city
  final ApiService _apiService = ApiService();
  final LocationStorageService _locationStorageService = LocationStorageService(); // Use new service

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkLoginStatus(); // Check login status on init
    _loadCurrentCityFromStorage(); // Load city from storage
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app resumes, re-check location data
      _loadCurrentCityFromStorage();
    }
  }

  Future<void> _loadCurrentCityFromStorage() async {
    final savedLocation = await _locationStorageService.getSavedCity();
    if (mounted) {
      setState(() {
        _currentCity = savedLocation?['city'];
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final token = await _apiService.getToken();
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  List<Widget> _getScreens() {
    return [
      const HomeScreen(),
      const CategoriesScreen(),
      const AddPostScreen(),
      const FavoritesScreen(),
      _isLoggedIn
          ? const ProfileScreen()
          : ProfileFlowScreen(onLoginSuccess: _handleLoginSuccess),
    ];
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
      _selectedIndex = 4; // Navigate to Profile tab after successful login
    });
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 2 || index == 3 || index == 4) { // Add Post, Favorites, Profile
      if (!_isLoggedIn) {
        // User is not logged in, navigate to ProfileFlowScreen
        setState(() {
          _selectedIndex = 4; // Set index to Profile tab
        });
        return; // Prevent navigating to other protected screens directly
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logoutUser() async {
    final result = await _apiService.logoutApi();
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        setState(() {
          _isLoggedIn = false; // Update login status
          _selectedIndex = 0; // Navigate to Home tab after logout
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to logout.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        title: Text(
          _getAppBarTitle(context, _selectedIndex), // Dynamic title, modify this line
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // if (_selectedIndex == 0) // Home screen specific actions
          //   Row(
          //     children: [
          //       const Icon(Icons.location_on_outlined, color: Colors.black),
          //       const SizedBox(width: 4),
          //       Text(
          //         _currentCity ?? 'Loading...',
          //         style: const TextStyle(fontSize: 16, color: Colors.black),
          //       ),
          //       const SizedBox(width: 16),
          //     ],
          //   ),
          if (_selectedIndex == 0) // Example: Home screen specific actions
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                // Handle notifications icon press
              },
            ),
          if (_selectedIndex == 4 && _isLoggedIn) // Profile screen specific actions
            IconButton(
              icon: const Icon(Icons.logout), // Replaced more_vert with logout icon
              onPressed: _logoutUser, // Call the logout method
              tooltip: 'Logout',
            ),
        ],
      ),
      drawer: const SideMenu(), // Add the SideMenu here
      body: _getScreens()[_selectedIndex], // Use _getScreens() here
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[ // Modify to remove const
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.home ?? 'Home', // Modify this line
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)?.categories ?? 'Categories', // Modify this line
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: AppLocalizations.of(context)?.addPost ?? 'Add Post', // Modify this line (need to add "addPost" to arb files)
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: AppLocalizations.of(context)?.favorites ?? 'Favorites', // Modify this line
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: _isLoggedIn
                ? (AppLocalizations.of(context)?.profile ?? 'Profile') // Modify this line
                : (AppLocalizations.of(context)?.loginSignup ?? 'Login/Signup'), // Modify this line (need to add "loginSignup" to arb files)
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(BuildContext context, int index) { // Modify this line
    switch (index) {
      case 0:
        return AppLocalizations.of(context)?.appTitle ?? 'Notices Info'; // Modify this line
      case 1:
        return AppLocalizations.of(context)?.categories ?? 'Categories'; // Modify this line
      case 2:
        return AppLocalizations.of(context)?.addPost ?? 'Add Post'; // Modify this line
      case 3:
        return AppLocalizations.of(context)?.favorites ?? 'Favorites'; // Modify this line
      case 4:
        return _isLoggedIn
            ? (AppLocalizations.of(context)?.profile ?? 'Profile') // Modify this line
            : (AppLocalizations.of(context)?.loginSignup ?? 'Login/Signup'); // Modify this line
      default:
        return AppLocalizations.of(context)?.appTitle ?? 'Notices Info'; // Modify this line
    }
  }
}
