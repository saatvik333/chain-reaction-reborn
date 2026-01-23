import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/player_provider.dart';
import 'custom_popup.dart';
import 'pill_button.dart';
import '../constants/app_strings.dart';
import '../constants/app_dimensions.dart';

class EditPlayerDialog extends StatefulWidget {
  final int playerIndex;

  const EditPlayerDialog({super.key, required this.playerIndex});

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final playerProvider = PlayerScope.of(context);
      _controller = TextEditingController(
        text: playerProvider.getName(widget.playerIndex),
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final playerProvider = PlayerScope.of(context);
    final playerColor = theme.currentTheme.getPlayerColor(
      widget.playerIndex,
      theme.isDarkMode,
    );

    return CustomPopup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimensions.iconS,
                height: AppDimensions.iconS,
                decoration: BoxDecoration(
                  color: playerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${AppStrings.editPlayerTitle} ${widget.playerIndex}',
                style: TextStyle(
                  color: theme.fg,
                  fontSize: AppDimensions.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          TextField(
            autofocus: true,
            controller: _controller,
            style: TextStyle(color: theme.fg),
            decoration: InputDecoration(
              labelText: AppStrings.nameLabel,
              labelStyle: TextStyle(color: theme.subtitle),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.fg),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  text: AppStrings.cancel,
                  onTap: () => Navigator.of(context).pop(),
                  height: 48,
                  borderColor: theme.border,
                  textColor: theme.subtitle,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: PillButton(
                  text: AppStrings.save,
                  onTap: () {
                    playerProvider.updateName(
                      widget.playerIndex,
                      _controller.text,
                    );
                    Navigator.of(context).pop();
                  },
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
