part of '../result_view.dart';

mixin ResultViewMixin on State<ResultView> {
  ResultBloc get _bloc => context.read<ResultBloc>();

  void onPlayAgainTapped() => context.go(RoutePaths.game.path);

  void onHomeTapped() => context.go(RoutePaths.home.path);

  void onShareTapped() => _bloc.add(const ResultShareTapped());

  void onClipDismissed() => _bloc.add(const ResultClipDismissed());

  Future<void> onStateChanged(BuildContext context, ResultState state) async {
    final clip = state.clip;
    if (state.clipStatus != ClipStatus.sharing || clip == null) return;
    final floor = '${state.result.floor}';
    final text = LocaleKeys.clip_share_text.tr(args: [floor]);
    final box = context.findRenderObject() as RenderBox?;
    try {
      await getIt<ClipShare>().share(
        file: clip.file,
        title: LocaleKeys.clip_share_subject.tr(args: [floor]),
        subtitle: LocaleKeys.clip_share_video.tr(args: ['${clip.seconds}']),
        text: clip.url == null ? text : '$text\n${clip.url}',
        origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      );
    } finally {
      if (mounted) _bloc.add(const ResultShareClosed());
    }
  }
}
