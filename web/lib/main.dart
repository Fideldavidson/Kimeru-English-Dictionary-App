import 'package:flutter/material.dart';
import 'admin/admin_login_page.dart';
import 'admin/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/github_service.dart';
import 'services/mock_github_service.dart';

import 'public/public_search_page.dart';

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
  bool _showAdmin = false; // Toggle for showing admin section

  // Use Real GitHub service
  late GitHubService _githubService;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    final token = await _authService.getToken();
    
    // Initialize service even if not logged in (for public view)
    _githubService = GitHubService(token: token); // Token may be null
    
    setState(() {
      _isLoggedIn = loggedIn;
      _initializing = false;
    });
  }

  void _onLoginSuccess() async {
    final token = await _authService.getToken();
    if (token != null) {
      _githubService = GitHubService(token: token);
      setState(() => _isLoggedIn = true);
    }
  }

  void _onLogout() async {
    await _authService.logout();
    setState(() {
      _isLoggedIn = false;
      _showAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimeru Dictionary',
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
          : _showAdmin
              ? _isLoggedIn
                  ? AdminDashboard(
                      githubService: _githubService,
                      onLogout: _onLogout,
                    )
                  : AdminLoginPage(onLoginSuccess: _onLoginSuccess)
              : PublicSearchPage(
                  githubService: _githubService,
                  onAdminLogin: () => setState(() => _showAdmin = true),
                ),
    );
  }
}
