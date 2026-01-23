import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/presentation/providers/theme_provider.dart';
import '../features/game/presentation/providers/player_names_provider.dart';
import 'custom_popup.dart';
import 'pill_button.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_dimensions.dart';

class EditPlayerDialog extends ConsumerStatefulWidget {
  final int playerIndex;

  const EditPlayerDialog({super.key, required this.playerIndex});

  @override
  ConsumerState<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends ConsumerState<EditPlayerDialog> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final currentName = ref.read(
        playerNamesProvider.select((s) => s.getName(widget.playerIndex)),
      );
      _controller = TextEditingController(text: currentName);
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
    final themeState = ref.watch(themeProvider);
    final playerColor = themeState.getPlayerColor(widget.playerIndex);

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
                  color: themeState.fg,
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
            style: TextStyle(color: themeState.fg),
            decoration: InputDecoration(
              labelText: AppStrings.nameLabel,
              labelStyle: TextStyle(color: themeState.subtitle),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: themeState.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: themeState.fg),
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
                  borderColor: themeState.border,
                  textColor: themeState.subtitle,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: PillButton(
                  text: AppStrings.save,
                  onTap: () {
                    ref
                        .read(playerNamesProvider.notifier)
                        .updateName(widget.playerIndex, _controller.text);
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
