import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../services/auth_service.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = false;
  String? _message;
  bool _isVerified = false;
  Timer? _timer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  static const int cooldownDuration = 60; // 60 seconds cooldown

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownSeconds = cooldownDuration;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_cooldownSeconds > 0) {
          setState(() {
            _cooldownSeconds--;
          });
        } else {
          _cooldownTimer?.cancel();
        }
      },
    );
  }

  Future<void> _startVerificationCheck() async {
    final authService = ref.read(authServiceProvider);
    
    if (authService.currentUser == null) {
      context.go('/sign-in');
      return;
    }

    if (authService.isEmailVerified) {
      setState(() => _isVerified = true);
      context.go('/home');
      return;
    }

    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    final authService = ref.read(authServiceProvider);

    await authService.reloadUser();

    if (authService.isEmailVerified) {
      setState(() => _isVerified = true);
      _timer?.cancel();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isLoading || _cooldownSeconds > 0) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendEmailVerification();
      if (mounted) {
        setState(() {
          _message = 'Verification email sent successfully';
        });
        _startCooldownTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e is AuthValidationException ? e.message : e.toString();
        });
        if (e is AuthValidationException && e.message == 'No user signed in') {
          context.pushReplacement('/sign-in');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _buttonText {
    if (_isLoading) {
      return 'Sending...';
    }
    if (_cooldownSeconds > 0) {
      return 'Resend in ${_cooldownSeconds}s';
    }
    return 'Resend Verification Email';
  }

  Future<void> _signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    if (mounted) {
      context.pushReplacement('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          const GradientBackground(useAltColors: true),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: Colors.white,
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Verify your Email',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'We\'ve sent you an email verification link. Please check your email and verify your account.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.3),
                  const SizedBox(height: AppConstants.spacingXXL),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('success') ? Colors.green[300] : Colors.red[300],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(),
                  CustomButton(
                    text: _buttonText,
                    onPressed: (_isLoading || _cooldownSeconds > 0) ? null : _resendVerificationEmail,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                  const SizedBox(height: AppConstants.spacingM),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 