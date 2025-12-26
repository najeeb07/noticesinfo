import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/settings_screen.dart';
import '../screens/all_posts_screen.dart'; // Import AllPostsScreen
import '../services/api_service.dart'; // Import ApiService
import 'package:noticesinfo/l10n/app_localizations.dart'; // Add this import

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFEDE7F6), // Light purple background
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/image/notices_logo.png', // Your logo asset
                  height: 50,
                  width: 50,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.appTitle ?? 'Notices Info', // Localize app title
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle Log In
                Navigator.pop(context); // Close the drawer
                // Navigate to login screen or perform login action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Text(
                AppLocalizations.of(context)?.loginSignup ?? 'Log In', // Localize Log In button
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildMenuItem(context, Icons.home, AppLocalizations.of(context)?.home ?? 'Home', () { // Localize Home
            Navigator.pop(context); // Close the drawer
            // Navigate to Home screen
          }),
          _buildMenuItem(context, Icons.whatshot, AppLocalizations.of(context)?.popularPosts ?? 'Popular Posts', () { // Localize Popular Posts (need to add "popularPosts" to arb files)
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPostsScreen(
                  title: AppLocalizations.of(context)?.popularPosts ?? 'Popular Posts', // Localize title
                  fetchPosts: ApiService().fetchPopularPosts,
                ),
              ),
            );
          }),
          _buildMenuItem(context, Icons.featured_play_list, AppLocalizations.of(context)?.latestPosts ?? 'Latest Posts', () { // Localize Latest Posts (need to add "latestPosts" to arb files)
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPostsScreen(
                  title: AppLocalizations.of(context)?.latestPosts ?? 'Latest Posts', // Localize title
                  fetchPosts: ApiService().fetchAllPosts,
                ),
              ),
            );
          }),
          _buildMenuItem(context, Icons.notifications, AppLocalizations.of(context)?.notifications ?? 'Notifications', () { // Localize Notifications (need to add "notifications" to arb files)
            Navigator.pop(context); // Close the drawer
            // Navigate to Notifications screen
          }),
          _buildMenuItem(context, Icons.book, AppLocalizations.of(context)?.blog ?? 'Blog', () { // Localize Blog (need to add "blog" to arb files)
            Navigator.pop(context); // Close the drawer
            // Navigate to Blog screen
          }),
          _buildMenuItem(context, Icons.settings, AppLocalizations.of(context)?.settings ?? 'Setting', () { // Localize Setting
            Navigator.pop(context); // Close the drawer
            Navigator.of(context).pushNamed(SettingsScreen.routeName);
          }),
          _buildMenuItem(context, Icons.contact_mail, AppLocalizations.of(context)?.contactUs ?? 'Contact Us', () async { // Localize Contact Us (need to add "contactUs" to arb files)
            Navigator.pop(context); // Close the drawer
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'info@noticesinfo.com',
              query: encodeQueryParameters(<String, String>{
                'subject': AppLocalizations.of(context)?.contactFromApp ?? 'Contact from Notices Info App', // Localize email subject (need to add "contactFromApp" to arb files)
              }),
            );
            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.couldNotLaunchEmail ?? 'Could not launch email app.')), // Localize snackbar message (need to add "couldNotLaunchEmail" to arb files)
              );
            }
          }),
          _buildMenuItem(context, Icons.star_rate, AppLocalizations.of(context)?.rateThisApp ?? 'Rate This App', () async { // Localize Rate This App (need to add "rateThisApp" to arb files)
            Navigator.pop(context); // Close the drawer
            final url = Uri.parse('https://play.google.com/store/apps/details?id=com.noticesinfo.app'); // Replace with your app's actual store URL
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              // Handle error, e.g., show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.couldNotLaunchStore ?? 'Could not launch store page.')), // Localize snackbar message (need to add "couldNotLaunchStore" to arb files)
              );
            }
          }),
          _buildMenuItem(context, Icons.share, AppLocalizations.of(context)?.shareThisApp ?? 'Share This App', () { // Localize Share This App (need to add "shareThisApp" to arb files)
            Navigator.pop(context); // Close the drawer
            Share.share(AppLocalizations.of(context)?.shareAppText ?? 'Check out this awesome app: https://play.google.com/store/apps/details?id=com.noticesinfo.app'); // Localize share text (need to add "shareAppText" to arb files)
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        title,
        style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
