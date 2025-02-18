import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthValidationException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();
      if (mounted && userCredential != null) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => context.go('/'),
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingM),
                  
                  Text(
                    AppLocalizations.of(context)!.signInToContinue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingXXL),
                  
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.email,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingL),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(begin: 0.3),
                  
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppConstants.spacingM),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(),
                  
                  const SizedBox(height: AppConstants.spacingM),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/reset-password'),
                      child: Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                  
                  const Spacer(),
                  
                  CustomButton(
                    text: _isLoading ? 'Signing In...' : AppLocalizations.of(context)!.signIn,
                    onPressed: _isLoading ? null : _signIn,
                    backgroundColor: AppTheme.primaryColor,
                    textColor: Colors.white,
                    isLoading: _isLoading,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(30),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1000)).slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingM),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1100)),
                  
                  const SizedBox(height: AppConstants.spacingM),
                  
                  CustomButton(
                    text: AppLocalizations.of(context)!.signInWithGoogle,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    iconWidget: Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        'assets/icons/google_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    isOutlined: true,
                    borderRadius: BorderRadius.circular(30),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1200)).slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingL),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dontHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.replace('/sign-up'),
                        child: Text(
                          AppLocalizations.of(context)!.signUp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1200)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 