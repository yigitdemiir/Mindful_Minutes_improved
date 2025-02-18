import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = AppLocalizations.of(context)!.pleaseEnterEmail;
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _message = AppLocalizations.of(context)!.resetLinkSent;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = e is AuthValidationException ? e.message : e.toString();
          _isSuccess = false;
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
                      onPressed: () => context.pop(),
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.resetPassword,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    AppLocalizations.of(context)!.resetPasswordDesc,
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
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppConstants.spacingM),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green[300] : Colors.red[300],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(),
                  const Spacer(),
                  CustomButton(
                    text: _isLoading ? AppLocalizations.of(context)!.sending : AppLocalizations.of(context)!.sendResetLink,
                    onPressed: _isLoading ? null : _resetPassword,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(begin: 0.3),
                  const SizedBox(height: AppConstants.spacingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.rememberPassword,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/sign-in'),
                        child: Text(
                          AppLocalizations.of(context)!.signIn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 