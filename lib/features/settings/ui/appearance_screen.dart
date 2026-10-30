import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../household/data/household_repository.dart';

/// Ustawienia → Wygląd (GUI 6): przełącznik trybu, kafelki motywów w trzech grupach,
/// podgląd na żywo (dotknięcie przebarwia ekran), zapis po „Zastosuj motyw”.
class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  String? _previewId;
  AppThemeMode? _previewMode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final themes = ref.watch(appThemesProvider);
    final profile = ref.watch(profileProvider).value;
    final savedId = profile?.themeId ?? defaultLightThemeId;
    final savedMode = AppThemeMode.parse(profile?.themeMode);
    final previewId = _previewId ?? savedId;
    final previewMode = _previewMode ?? savedMode;
    final pair = resolveThemePair(themes, previewId);
    final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final useDark = switch (previewMode) {
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.auto => platformDark,
    };
    final preview = useDark ? pair.dark : pair.light;
    final dirty = previewId != savedId || previewMode != savedMode;

    void apply() {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid == null) return;
      ref
          .read(householdRepositoryProvider)
          .saveTheme(uid: uid, themeId: previewId, themeMode: previewMode.name)
          .catchError((Object _) {});
      setState(() {
        _previewId = null;
        _previewMode = null;
      });
      showAppToast(context, l.themeApplied);
    }

    // Podgląd na żywo: cały ekran ustawień w wybranym motywie.
    return Theme(
      data: buildTheme(preview),
      child: Builder(
        builder: (context) {
          final t = context.tokens;
          final text = Theme.of(context).textTheme;
          return ScreenScaffold(
            title: l.appearanceTitle,
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: l.back,
            bottom: PrimaryButton(label: l.themeApply, onPressed: dirty ? apply : null),
            children: [
              Text(l.themeModeLabel, style: text.titleMedium),
              SegmentedSwitch<AppThemeMode>(
                options: [
                  SegmentOption(AppThemeMode.light, l.themeModeLight),
                  SegmentOption(AppThemeMode.dark, l.themeModeDark),
                  SegmentOption(AppThemeMode.auto, l.themeModeAuto),
                ],
                value: previewMode,
                onChanged: (m) => setState(() => _previewMode = m),
              ),
              Text(l.themeModeHint, style: text.labelMedium),
              if (previewMode == AppThemeMode.auto)
                Text(platformDark ? l.themeAutoDarkHint : l.themeAutoLightHint, style: text.labelMedium!.copyWith(color: t.warning)),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(preview.name, style: text.titleLarge),
                    const SizedBox(height: 6),
                    Text(l.themeSample, style: text.bodyMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StatusChip(label: l.visibilityAll, tone: ChipTone.accent),
                        const SizedBox(width: 8),
                        StatusChip(label: l.chipDone, tone: ChipTone.success),
                        const SizedBox(width: 8),
                        StatusChip(label: l.chipTodo, tone: ChipTone.warning),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CheckRow(title: l.themeSample, checked: true, onChanged: (_) {}),
                  ],
                ),
              ),
              Text(l.themePreviewHint, style: text.labelMedium),
              for (final entry in themes.groups.entries) ...[
                Text(entry.key, style: text.titleMedium),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final theme in entry.value)
                      _ThemeTile(
                        theme: theme,
                        selected: theme.id == previewId,
                        borderColor: t.accent,
                        onTap: () => setState(() {
                          _previewId = theme.id;
                          // Wybrany motyw ma być widoczny od razu: tryb podąża za jego jasnością.
                          _previewMode = theme.brightness == Brightness.light ? AppThemeMode.light : AppThemeMode.dark;
                        }),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Kafelek motywu: miniatura w jego własnych kolorach (to jedyne miejsce, gdzie kolory innego
/// motywu są rysowane celowo – pochodzą z tokenów, nie z hexów w widgecie).
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.theme, required this.selected, required this.borderColor, required this.onTap});

  final AppTokens theme;
  final bool selected;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: theme.name,
      excludeSemantics: true,
      child: Material(
        color: theme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? borderColor : theme.border, width: selected ? 3 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 104,
            height: 92,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        Container(width: 24, height: 6, decoration: BoxDecoration(color: theme.text, borderRadius: BorderRadius.circular(3))),
                        const Spacer(),
                        Container(width: 16, height: 10, decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    theme.name,
                    style: text.labelSmall!.copyWith(color: theme.text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
