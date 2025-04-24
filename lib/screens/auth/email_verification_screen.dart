import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/services/auth_service.dart';
import 'package:budgeto/screens/home_screen.dart';
import 'package:budgeto/widgets/custom_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResendEmail = true;
  int _resendTimeout = 0;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Since we're using local storage, we'll simulate email verification
      // In a real app, you would implement actual email verification
      if (authService.isEmailVerified) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isVerified = true;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;
    
    setState(() {
      _canResendEmail = false;
      _resendTimeout = 60;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.sendEmailVerification();
    
    // Start countdown timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResendEmail = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendTimeout--;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final email = authService.email ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'We\'ve sent a verification email to:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Please check your email and click on the verification link to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Error message
              if (authService.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authService.error!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              if (authService.error != null) const SizedBox(height: 16),
              
              // Resend button
              CustomButton(
                text: _canResendEmail
                    ? 'Resend Verification Email'
                    : 'Resend in $_resendTimeout seconds',
                isLoading: authService.isLoading,
                onPressed: _canResendEmail ? _resendVerificationEmail : null,
              ),
              const SizedBox(height: 16),
              
              // Check verification button
              OutlinedButton(
                onPressed: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  
                  // Since we're using local storage, we'll simulate email verification
                  // In a real app, you would implement actual email verification
                  if (authService.isEmailVerified) {
                    if (mounted) {
                      setState(() {
                        _isVerified = true;
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('I\'ve verified my email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}