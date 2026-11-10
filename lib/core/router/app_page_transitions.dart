import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sayfa geçişleri.
abstract final class AppPageTransitions {
  /// Açılış / oyun sonu -> ana sayfa: yumuşak geçiş, içerik hafifçe büyür.
  static Page<void> fadeScale(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        name: state.name,
        child: child,
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );

  /// Ana sayfa -> oyun: binaya "dalış" (yakınlaşarak açılır, geri dönerken
  /// uzaklaşarak kapanır).
  static Page<void> zoom(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        name: state.name,
        child: child,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 1.08, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );

  /// Oyun sonu: aşağıdan hafif kayarak gelir.
  static Page<void> fadeUp(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        name: state.name,
        child: child,
        transitionDuration: const Duration(milliseconds: 480),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );

  /// Ayarlar: alttaki ekranın üstünde saydam katman (Figma: scrim + kart).
  static Page<void> overlay(GoRouterState state, Widget child) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        name: state.name,
        child: child,
        opaque: false,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            ),
      );
}
