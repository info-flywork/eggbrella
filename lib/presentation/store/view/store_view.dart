import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/theme/app_spacing.dart';
import 'package:eggbrella/core/theme/app_text_styles.dart';
import 'package:eggbrella/core/widgets/app_buttons.dart';
import 'package:eggbrella/core/widgets/app_hud.dart';
import 'package:eggbrella/core/widgets/app_modal_card.dart';
import 'package:eggbrella/core/widgets/app_motion.dart';
import 'package:eggbrella/core/widgets/app_pressable.dart';
import 'package:eggbrella/core/widgets/app_toggle.dart';
import 'package:eggbrella/core/widgets/app_yumi.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/store/coin_pack.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:eggbrella/generated/colors.gen.dart';
import 'package:eggbrella/generated/locale_keys.g.dart';
import 'package:eggbrella/presentation/store/bloc/store_bloc.dart';
import 'package:eggbrella/presentation/store/bloc/store_event.dart';
import 'package:eggbrella/presentation/store/bloc/store_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/store_view_mixin.dart';
part 'widgets/store_coin_list.dart';
part 'widgets/store_panel.dart';
part 'widgets/store_skin_grid.dart';

/// Mağaza: üstte başlık + bakiye ve Yumi önizlemesi; altta krem panelde
/// sekmeler (Yumurta / Şemsiye / Coin), ürünler ve işlem butonu. Ürünler
/// kaydırılmadan tamamı panelde görünür.
class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> with StoreViewMixin {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: BlocConsumer<StoreBloc, StoreState>(
        listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
        listener: onStateChanged,
        builder: (context, state) => Stack(
          fit: StackFit.expand,
          children: [
            AppBackground(image: Assets.images.imgBgSky),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    top + AppSpacing.xs,
                    AppSpacing.m,
                    0,
                  ),
                  child: _Header(coins: state.coins, onClose: onCloseTapped),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AppFloat(
                      amplitude: 6,
                      child: AppYumi(
                        key: ValueKey(state.preview.key),
                        pose: YumiPose.happy,
                        skins: state.preview,
                      ),
                    ),
                  ),
                ),
                StorePanel(
                  state: state,
                  onTabChanged: onTabChanged,
                  onSkinTapped: onSkinTapped,
                  onSkinBuyTapped: onSkinBuyTapped,
                  onCoinPackTapped: onCoinPackTapped,
                  onRestoreTapped: onRestoreTapped,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coins, required this.onClose});

  final int coins;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppCircleIconButton(
              icon: Assets.icons.icClose.svg(),
              semanticLabel: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: onClose,
            ),
          ),
          AppBanner(label: LocaleKeys.store_title.tr()),
          Align(
            alignment: Alignment.centerRight,
            child: AppCoinPill(amount: '$coins'),
          ),
        ],
      ),
    );
  }
}
