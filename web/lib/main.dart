import 'package:flutter/material.dart';
import 'admin/admin_login_page.dart';
import 'admin/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/github_service.dart';
import 'services/mock_github_service.dart';

void main() {
  runApp(const KimeruWebPortal());
}

class KimeruWebPortal extends StatefulWidget {
  const KimeruWebPortal({super.key});

  @override
  State<KimeruWebPortal> createState() => _KimeruWebPortalState();
}

class _KimeruWebPortalState extends State<KimeruWebPortal> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _initializing = true;

  // Use Mock service for testing
  final GitHubService _githubService = MockGitHubService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _initializing = false;
    });
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() async {
    await _authService.logout();
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimeru Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A5F7A),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1A5F7A),
          foregroundColor: Colors.white,
        ),
      ),
      home: _initializing
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isLoggedIn
              ? AdminDashboard(
                  githubService: _githubService,
                  onLogout: _onLogout,
                )
              : AdminLoginPage(onLoginSuccess: _onLoginSuccess),
    );
  }
}
