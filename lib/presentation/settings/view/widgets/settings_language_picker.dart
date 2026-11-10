part of '../settings_view.dart';

/// Dil seçimi (Figma'da "Belirsiz"): ayar kartı diliyle küçük bir kart.
Future<Locale?> showSettingsLanguagePicker(BuildContext context) {
  final current = context.locale;
  return showDialog<Locale>(
    context: context,
    barrierColor: ColorName.colorScrim,
    builder: (context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Material(
          type: MaterialType.transparency,
          child: AppModalCard(
            banner: LocaleKeys.settings_language_title.tr(),
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  // Kenarlar sert kesilmesin: üst / alt yumuşakça söner.
                  child: AppScrollFade(
                    child: SingleChildScrollView(
                      // Butonların gölgesi yanlarda kesilmesin.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final locale in AppInit.supportedLocales) ...[
                            _LanguageOption(
                              label: 'language.${locale.languageCode}'.tr(),
                              selected:
                                  locale.languageCode == current.languageCode,
                              onTap: () => Navigator.of(context).pop(locale),
                            ),
                            const SizedBox(height: AppSpacing.s),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                AppTextButton(
                  label: LocaleKeys.common_cancel.tr(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => selected
      ? AppPrimaryButton(label: label, onPressed: onTap)
      : AppSecondaryButton(label: label, onPressed: onTap);
}
