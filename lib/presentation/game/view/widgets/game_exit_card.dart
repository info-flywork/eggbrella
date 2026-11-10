part of '../game_view.dart';

/// Figma cikis-onayi: "Ana sayfaya dönülsün mü?" (skor rekora sayılır).
class GameExitCard extends StatelessWidget {
  const GameExitCard({
    required this.floor,
    required this.onStay,
    required this.onLeave,
    super.key,
  });

  final int floor;
  final VoidCallback onStay;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      banner: LocaleKeys.exit_confirm_title.tr(),
      imageSize: const Size(130, 140),
      headline: LocaleKeys.exit_confirm_headline.tr(),
      message: LocaleKeys.exit_confirm_message.tr(args: ['$floor']),
      actions: [
        AppPrimaryButton(
          label: LocaleKeys.exit_confirm_stay.tr(),
          leading: Assets.images.icons.icPlay.image(width: 28, height: 28),
          onPressed: onStay,
        ),
        AppSecondaryButton(
          label: LocaleKeys.exit_confirm_leave.tr(),
          leading: Assets.images.icons.icHome.image(width: 28, height: 28),
          onPressed: onLeave,
        ),
      ],
    );
  }
}
