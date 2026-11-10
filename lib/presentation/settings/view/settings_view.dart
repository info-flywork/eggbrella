import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/init/app_init.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/utils/constants/string_constants.dart';
import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:eggbrella/core/widgets/app_buttons.dart';
import 'package:eggbrella/core/widgets/app_modal_card.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_toggle.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:eggbrella/domain/store/coin_store.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_bloc.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_event.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'mixin/settings_view_mixin.dart';
part 'widgets/settings_card.dart';
part 'widgets/settings_language_picker.dart';
part 'widgets/settings_rows.dart';

/// Figma ayarlar: alttaki ekranın üstünde scrim + ayar kartı.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SettingsViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(onTap: onCloseTapped, child: const AppScrim()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) => switch (state) {
                    SettingsInitial() => const SizedBox.shrink(),
                    SettingsLoaded() => AppEntrance(
                      scaleFrom: 0.94,
                      offset: const Offset(0, 16),
                      curve: Curves.easeOutBack,
                      child: SettingsCard(
                        state: state,
                        languageName: languageName,
                        onSoundChanged: onSoundChanged,
                        onMusicChanged: onMusicChanged,
                        onHapticChanged: onHapticChanged,
                        onControlChanged: onControlChanged,
                        onLanguageTapped: onLanguageTapped,
                        onPrivacyTapped: onPrivacyTapped,
                        onRestoreTapped: onRestoreTapped,
                        onCloseTapped: onCloseTapped,
                      ),
                    ),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
