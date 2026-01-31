import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ThemeState theme;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.theme,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30.0); // Pill shape

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: theme.fg),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.subtitle),
        prefixIcon: Icon(
          icon,
          color: theme.subtitle,
          size: AppDimensions.iconM,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: theme.playerColors.first, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}