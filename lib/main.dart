import 'dart:convert';
import 'package:application/core/themes/themes.dart';
import 'package:application/generated_routes.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentsDirectory.path);
  final box = await Hive.openBox('authtoken');
  final token = box.get('token');

  runApp(MyApp(token: token));

  // Check for updates after the app starts
  _checkForUpdate();
  await box.close();
}
// Function to check for updates
Future<void> _checkForUpdate() async {
  const String currentVersion = "3.0.0"; // Your app's current version

  try {
    final response = await http.get(
      Uri.parse('https://my-biometric.vercel.app/version.json'), // Replace with your server URL
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String latestVersion = data['version'];
      String updateUrl = data['update_url'];

      if (_isNewVersionAvailable(currentVersion, latestVersion)) {
        // Show update dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdateDialog(latestVersion, updateUrl);
        });
      }
    } else {
      print("Failed to fetch version info.");
    }
  } catch (e) { 
    print("Error checking for updates: $e");
  }
}

// Helper function to compare current version and latest version
bool _isNewVersionAvailable(String current, String latest) {
  List<String> currentParts = current.split('.');
  List<String> latestParts = latest.split('.');

  for (int i = 0; i < currentParts.length; i++) {
    int currentPart = int.parse(currentParts[i]);
    int latestPart = int.parse(latestParts[i]);

    if (latestPart > currentPart) {
      return true;
    } else if (latestPart < currentPart) {
      return false;
    }
  }
  return false;
}

// Function to show update dialog
void _showUpdateDialog(String latestVersion, String updateUrl) {
  showDialog(
    context: MyApp.navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text("Update Available"),
      content: Text(
        "A new version ($latestVersion) of this app is available. Would you like to update?"
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Later"),
        ),
        TextButton(
          onPressed: () async {
            Uri updateUri = Uri.parse(updateUrl);
            if (await canLaunchUrl(updateUri)) {
              await launchUrl(updateUri);
            } else {
              print("Could not launch $updateUrl");
            }
          },
          child: Text("Update"),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  final dynamic token;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Routes.onGenerate,
      initialRoute: (token != null) ? "/home" : "/login",
      theme: AppTheme.appTheme,
      title: "Vsense Biometrics",
      navigatorKey: navigatorKey, // Setting navigator key for dialogs
    );
  }
}
