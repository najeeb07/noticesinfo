import 'package:flutter/material.dart';
import 'package:noticesinfo/screens/generic_content_screen.dart';
import 'package:noticesinfo/screens/faq_screen.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:noticesinfo/l10n/app_localizations.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:noticesinfo/main.dart'; // Add this import
import 'package:noticesinfo/screens/profile_edit_screen.dart'; // Add this import
// No longer need to import login_screen or profile_flow_screen directly here for navigation

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _navigateToContentScreen(
      BuildContext context, String title, String url) async {
    try {
      final response = await _apiService.fetchData(url);
      if (response['success'] == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => GenericContentScreen(
              title: title,
              content: response['data']['content'],
            ),
          ),
        );
      } else {
        // Handle error, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load $title')),
        );
      }
    } catch (error) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'), // Modify this line
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, AppLocalizations.of(context)?.configuration ?? 'Configuration'), // Modify this line
          _buildSettingItem(context, AppLocalizations.of(context)?.accountSetting ?? 'Account Setting', onTap: () async {
            final isLoggedIn = await _apiService.getToken() != null;
            if (isLoggedIn) {
              Navigator.of(context).pushNamed(ProfileEditScreen.routeName).then((result) {
                if (result == true) {
                  // Optionally refresh profile data if needed, or rely on ProfileScreen's initState to reload on pop
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.pleaseLoginToUpdateProfile ?? 'Please log in to update your profile.')),
              );
              // Navigate to MainScreen with the profile tab selected to initiate login flow
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 4)),
                (Route<dynamic> route) => false,
              );
            }
          }),
          _buildDivider(),
          _buildSettingItem(context, AppLocalizations.of(context)?.language ?? 'Language', onTap: () { // Modify this line
            _showLanguagePickerDialog(context); // Add this line
          }),
          _buildDivider(),
          _buildToggleSettingItem(context, AppLocalizations.of(context)?.pushNotifications ?? 'Push Notifications', true, (value) { // Modify this line (need to add "pushNotifications" to arb files)
            // Handle Push Notifications toggle
          }),
          _buildDivider(),
          _buildSectionTitle(context, AppLocalizations.of(context)?.about ?? 'About'), // Modify this line
          _buildSettingItem(context, AppLocalizations.of(context)?.termsConditions ?? 'Terms & Conditions', onTap: () { // Modify this line (need to add "termsConditions" to arb files)
            _navigateToContentScreen(context, AppLocalizations.of(context)?.termsConditions ?? 'Terms & Conditions', '/terms'); // Modify this line
          }),
          _buildDivider(),
          _buildSettingItem(context, AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy', onTap: () { // Modify this line (need to add "privacyPolicy" to arb files)
            _navigateToContentScreen(context, AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy', '/privacy-policy'); // Modify this line
          }),
          _buildDivider(),
          _buildSettingItem(context, AppLocalizations.of(context)?.frequentlyAskedQuestions ?? 'Frequently Asked Questions', onTap: () { // Modify this line (need to add "frequentlyAskedQuestions" to arb files)
            Navigator.of(context).pushNamed(FaqScreen.routeName);
          }),
          _buildDivider(),
          _buildSettingItem(context, AppLocalizations.of(context)?.appInfo ?? 'App Info', onTap: () { // Modify this line (need to add "appInfo" to arb files)
            // Navigate to App Info screen
          }),
          _buildDivider(),
          _buildAppVersionItem(context, AppLocalizations.of(context)?.appVersion ?? 'App Version', _appVersion), // Modify this line (need to add "appVersion" to arb files)
        ],
      ),
    );
  }

  void _showLanguagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.selectLanguage ?? 'Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, 'English', 'en'),
                _buildLanguageOption(context, 'हिंदी', 'hi'),
                _buildLanguageOption(context, 'العربية', 'ar'),
                _buildLanguageOption(context, 'తెలుగు', 'te'),
                _buildLanguageOption(context, 'தமிழ்', 'ta'),
                _buildLanguageOption(context, 'മലയാളം', 'ml'),
                _buildLanguageOption(context, 'ಕನ್ನಡ', 'kn'),
                _buildLanguageOption(context, 'বাংলা', 'bn'),
                _buildLanguageOption(context, 'اردو', 'ur'),
                _buildLanguageOption(context, '中文', 'zh'),
                _buildLanguageOption(context, 'Deutsch', 'de'),
                _buildLanguageOption(context, 'Français', 'fr'),
                _buildLanguageOption(context, 'Español', 'es'),
                _buildLanguageOption(context, 'සිංහල', 'si'),
                _buildLanguageOption(context, 'Bahasa Indonesia', 'id'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageName, String languageCode) { // Add this method
    return ListTile( // Add this line
      title: Text(languageName), // Add this line
      onTap: () async { // Add this line
        final prefs = await SharedPreferences.getInstance(); // Add this line
        await prefs.setString('language_code', languageCode); // Add this line
        myAppKey.currentState?.setLocale(Locale(languageCode)); // Modify this line
        Navigator.of(context).pop(); // Add this line
      }, // Add this line
    ); // Add this line
  } // Add this line

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersionItem(BuildContext context, String title, String version) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            version,
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 16, endIndent: 16);
  }
}
