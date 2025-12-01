import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/finance_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'localization/app_localizations.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..initialize(),
      child: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Hishab - Finance Tracker',
            debugShowCheckedModeBanner: false,
            locale: provider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('bn', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: provider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: const Color(0xFFF16725),
                secondary: const Color(0xFF0066CC),
                tertiary: const Color(0xFF9C4A24),
                surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: const Color(0xFF231F20),
                surfaceContainerHighest: const Color.fromARGB(255, 255, 245, 243),
              ),
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFFF16725),
                secondary: const Color(0xFF0066CC),
                tertiary: const Color(0xFF9C4A24),
                surface: const Color(0xFF231F20),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: const Color(0xFFFBD3C0),
                surfaceContainerHighest: const Color(0xFF2D2A2B),
              ),
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: const Color(0xFF231F20),
              appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    // Wait for a moment to show splash
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;
    final hasSetIncome = prefs.getBool('income_set') ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!hasSetIncome) {
      // If they've seen onboarding but haven't set income, go to home
      // (they might have skipped income setup)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4ECDC4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hishab',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনার খরচ ট্র্যাক করুন',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
