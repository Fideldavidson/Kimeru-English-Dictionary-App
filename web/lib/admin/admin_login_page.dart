import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AdminLoginPage({super.key, required this.onLoginSuccess});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _error = false;
  bool _loading = false;

  void _handleLogin() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final success = await _authService.login(_passwordController.text);

    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, size: 64, color: Color(0xFF1A5F7A)),
              const SizedBox(height: 24),
              const Text(
                'Admin Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'GitHub Personal Access Token',
                  hintText: 'ghp_...',
                  errorText: _error ? 'Invalid token' : null,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5F7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
