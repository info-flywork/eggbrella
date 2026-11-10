part of '../game_view.dart';

/// Oyun dünyası: arka plan, engeller, altınlar ve Yumi (tek CustomPaint).
class GameWorldLayer extends StatelessWidget {
  const GameWorldLayer({required this.controller, super.key});

  final GameWorldController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / GameConfig.worldWidth;
        controller.setViewHeight(constraints.maxHeight / scale);
        return ExcludeSemantics(
          child: RepaintBoundary(
            child: CustomPaint(
              size: constraints.biggest,
              painter: ScenePainter(
                renderer: controller.renderer,
                snapshot: controller.snapshot,
                time: () => controller.time,
                repaint: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
