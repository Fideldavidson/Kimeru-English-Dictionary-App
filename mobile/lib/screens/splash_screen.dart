import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/data_seeder.dart';
import '../widgets/google_loader.dart';
import '../providers/word_provider.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Seed the database (only if empty)
    await DataSeeder.seed();
    
    // 2. Fetch the word of the day
    if (mounted) {
      await context.read<WordProvider>().fetchWordOfTheDay();
    }

    // 3. Small delay for smooth transition
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo / Brand Name — uses Serif font from theme
            Text(
              'Kimeru Dictionary',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const GoogleLoader(),
          ],
        ),
      ),
    );
  }
}
