import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/features/game/presentation/providers/theme_provider.dart';
import 'package:chain_reaction/widgets/pill_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chain_reaction/core/constants/app_strings.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.fg,
            size: AppDimensions.iconM,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.infoTitle,
          style: TextStyle(
            color: theme.fg,
            fontSize: AppDimensions.fontXL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(AppStrings.howToPlayHeader, theme),
              const SizedBox(height: AppDimensions.paddingM),
              _buildBulletPoint(AppStrings.htpBullet1, theme),
              const SizedBox(height: AppDimensions.paddingM),
              _buildBulletPoint(AppStrings.htpBullet2, theme),
              const SizedBox(height: AppDimensions.paddingM),
              _buildBulletPoint(AppStrings.htpBullet3, theme),

              const SizedBox(height: AppDimensions.paddingXL),
              Divider(color: theme.border, thickness: 1),
              const SizedBox(height: AppDimensions.paddingXL),

              _buildSectionHeader(AppStrings.aboutHeader, theme),
              const SizedBox(height: AppDimensions.paddingM),
              _buildInfoRow(
                AppStrings.versionLabel,
                AppStrings.defaultVersion,
                theme,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildInfoRow(
                AppStrings.developerLabel,
                AppStrings.developerName,
                theme,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildActionRow(
                AppStrings.privacyPolicy,
                Icons.arrow_outward,
                () {},
                theme,
              ),

              const SizedBox(height: AppDimensions.paddingXL),
              Divider(color: theme.border, thickness: 1),
              const SizedBox(height: AppDimensions.paddingXL),

              _buildSectionHeader(AppStrings.supportHeader, theme),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                AppStrings.supportMessage,
                style: TextStyle(
                  color: theme.subtitle,
                  fontSize: AppDimensions.fontS,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              PillButton(
                text: AppStrings.contactMe,
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: AppStrings.supportEmail,
                  );
                  try {
                    await launchUrl(emailLaunchUri);
                  } catch (e) {
                    // Handle error silently or show toast
                  }
                },
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeState theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.subtitle,
        fontSize: 12, // Usually smallest font
        fontWeight: FontWeight.bold,
        letterSpacing: AppDimensions.letterSpacingHeader,
      ),
    );
  }

  Widget _buildBulletPoint(String text, ThemeState theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: theme.fg, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.fg,
              fontSize: AppDimensions.fontM,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeState theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.subtitle,
            fontSize: AppDimensions.fontM,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.fg,
            fontSize: AppDimensions.fontM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    String label,
    IconData icon,
    VoidCallback onTap,
    ThemeState theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.subtitle,
              fontSize: AppDimensions.fontM,
            ),
          ),
          Icon(icon, color: theme.subtitle, size: AppDimensions.iconS),
        ],
      ),
    );
  }
}
