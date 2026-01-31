import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/presentation/widgets/responsive_container.dart';
import '../../../../core/theme/providers/theme_provider.dart';
import '../../domain/entities/app_auth_state.dart';
import '../providers/auth_provider.dart';
import '../../../../core/presentation/widgets/pill_button.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_tab_selector.dart';

/// Authentication screen for login and signup.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isLogin) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    if (isLogin) {
      await notifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await notifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : null,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final theme = ref.read(themeProvider);

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email first',
            style: TextStyle(color: theme.bg),
          ),
          backgroundColor: theme.fg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent!',
              style: TextStyle(color: theme.bg),
            ),
            backgroundColor: theme.fg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: TextStyle(color: theme.bg)),
            backgroundColor: theme.fg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final isLogin = ref.watch(authModeProvider);

    // Listen for auth state changes
    ref.listen(authProvider, (_, state) {
      state.when(
        initial: () {},
        loading: () {},
        authenticated: (userId, email, displayName, avatarUrl, profile) {
          ref.read(homeProvider.notifier).enterOnlineMode();
          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome, ${displayName ?? email}!',
                  style: TextStyle(color: theme.bg),
                ),
                backgroundColor: theme.fg,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        unauthenticated: () {},
        error: (message) {
          final isConfirmationMessage =
              message.toLowerCase().contains('confirmation email') ||
              message.toLowerCase().contains('check your inbox');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isConfirmationMessage
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: theme.bg,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(message, style: TextStyle(color: theme.bg)),
                  ),
                ],
              ),
              backgroundColor: theme.fg,
              duration: Duration(seconds: isConfirmationMessage ? 5 : 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          ref.read(authProvider.notifier).clearError();
        },
      );
    });

    final isLoading = authState is AppAuthStateLoading;

    return Container(
      color: theme.bg,
      child: ResponsiveContainer(
        child: Scaffold(
          backgroundColor: theme.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.fg,
                size: AppDimensions.iconM,
              ),
              onPressed: () {
                ref.read(authModeProvider.notifier).set(true);
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              isLogin ? 'Welcome Back' : 'Create Account',
              style: TextStyle(
                color: theme.fg,
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab Selector
                          AuthTabSelector(
                            isLogin: isLogin,
                            onModeChanged: (val) =>
                                ref.read(authModeProvider.notifier).set(val),
                            theme: theme,
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),

                          // Slot 1: Email (Stable for both)
                          AuthTextField(
                            key: const ValueKey('slot1_email'),
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            theme: theme,
                            validator: (v) => _validateEmail(v),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Slot 2: Password (Stable for both)
                          AuthTextField(
                            key: const ValueKey('slot2_password'),
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            theme: theme,
                            suffixIcon: _buildPasswordSuffix(theme),
                            validator: (v) => _validatePassword(v, isLogin),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Slot 3: Morphing Area (Forgot Password <-> Username Input)
                          SizedBox(
                            height: 72,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              child: isLogin
                                  ? Container(
                                      key: const ValueKey('slot3_forgot'),
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        right: 12,
                                      ),
                                      child: TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : _resetPassword,
                                        style: ButtonStyle(
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                          padding: WidgetStateProperty.all(
                                            EdgeInsets.zero,
                                          ),
                                          minimumSize: WidgetStateProperty.all(
                                            Size.zero,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor:
                                              WidgetStateProperty.resolveWith((
                                                states,
                                              ) {
                                                if (states.contains(
                                                  WidgetState.pressed,
                                                )) {
                                                  return theme.fg;
                                                }
                                                return theme.subtitle;
                                              }),
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: AppDimensions.fontS,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : AuthTextField(
                                      key: const ValueKey('slot3_username'),
                                      controller: _usernameController,
                                      label: 'Username',
                                      icon: Icons.person_outline,
                                      theme: theme,
                                      validator: (v) =>
                                          _validateUsername(v, isLogin),
                                    ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),

                          // Submit Button
                          PillButton(
                            text: isLogin ? 'Sign In' : 'Sign Up',
                            type: PillButtonType.primary,
                            onTap: () => _submit(isLogin),
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: AppDimensions.paddingL),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingM,
                                ),
                                child: Text(
                                  'or',
                                  style: TextStyle(color: theme.subtitle),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.border)),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingL),

                          // Google Sign In
                          PillButton(
                            text: isLogin
                                ? 'Sign in with Google'
                                : 'Sign up with Google',
                            type: PillButtonType.secondary,
                            onTap: isLoading ? null : _signInWithGoogle,
                            icon: FaIcon(
                              FontAwesomeIcons.google,
                              color: theme.fg,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSuffix(ThemeState theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0),
      child: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: theme.subtitle,
          size: AppDimensions.iconM,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        splashRadius: 20,
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          splashFactory: InkRipple.splashFactory,
          highlightColor: theme.fg.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  // Validators
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value, bool isLogin) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Only enforce min length for Sign Up
    if (!isLogin && value.length < 6) {
      return 'Min 6 characters';
    }
    return null;
  }

  String? _validateUsername(String? value, bool isLogin) {
    if (isLogin) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }
}
