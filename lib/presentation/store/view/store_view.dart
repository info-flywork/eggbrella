import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/haptics/haptic_manager.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
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
part 'widgets/store_coin_burst.dart';
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
  /// Son dokunuş (coin patlamasının çıkış noktası) ve bakiye hapı.
  Offset? _lastTap;
  final GlobalKey _pillKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  /// Coin animasyonu sürerken gösterilen bakiye ve hap zıplaması.
  final ValueNotifier<(int, double)?> _pill = ValueNotifier(null);
  ({int id, Offset from, Offset target, int fromCoins, int toCoins})? _burst;

  @override
  void dispose() {
    _pill.dispose();
    super.dispose();
  }

  /// Coin satın alındı: [credited] coin bakiyeye uçarak eklenir.
  @override
  void startCoinBurst({required int credited, required int newBalance}) {
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final pill = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || pill == null) return;
    final size = stack.size;
    final tap = _lastTap;
    final from = tap != null
        ? stack.globalToLocal(tap)
        : Offset(size.width / 2, size.height * 0.75);
    // Hapın solundaki coin ikonunun merkezi.
    final target = stack.globalToLocal(
      pill.localToGlobal(Offset(22, pill.size.height / 2)),
    );
    final fromCoins = newBalance - credited;
    _pill.value = (fromCoins, 0);
    setState(() {
      _burst = (
        id: (_burst?.id ?? 0) + 1,
        from: from,
        target: target,
        fromCoins: fromCoins,
        toCoins: newBalance,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final burst = _burst;
    return Scaffold(
      body: Listener(
        onPointerDown: (e) => _lastTap = e.position,
        child: BlocConsumer<StoreBloc, StoreState>(
          listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
          listener: onStateChanged,
          builder: (context, state) => Stack(
            key: _stackKey,
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
                    child: ValueListenableBuilder(
                      valueListenable: _pill,
                      builder: (context, pill, _) => _Header(
                        coins: pill?.$1 ?? state.coins,
                        bump: pill?.$2 ?? 0,
                        pillKey: _pillKey,
                        onClose: onCloseTapped,
                      ),
                    ),
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
              if (burst != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: StoreCoinBurst(
                      key: ValueKey(burst.id),
                      from: burst.from,
                      target: burst.target,
                      fromCoins: burst.fromCoins,
                      toCoins: burst.toCoins,
                      onFrame: (coins, bump) => _pill.value = (coins, bump),
                      onDone: () {
                        if (!mounted) return;
                        _pill.value = null;
                        setState(() => _burst = null);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.coins,
    required this.bump,
    required this.pillKey,
    required this.onClose,
  });

  final int coins;

  /// Coin varışında hap zıplaması (0..1).
  final double bump;
  final GlobalKey pillKey;
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
            child: Transform.scale(
              scale: 1 + 0.14 * Curves.easeOut.transform(bump),
              child: AppCoinPill(key: pillKey, amount: '$coins'),
            ),
          ),
        ],
      ),
    );
  }
}
