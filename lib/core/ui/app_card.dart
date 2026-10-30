import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_icon.dart';

/// Karta (GUI 5.2): surface, obrys 1 dp, promień 20, padding 18.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.semanticsLabel,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.icon,
  });

  final Widget child;
  final String? title;

  /// Ikona modułu w kółku `accentSoft` przed tytułem (GUI 2: promień 12–14 dp).
  final AppIcons? icon;

  /// Nadpisanie tła i obrysu (np. przypięta notatka: obrys 2 dp accent; prywatna: tło background).
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  /// Licznik lub akcja po prawej od tytułu.
  final Widget? trailing;

  /// Karta klikalna w całości dostaje strzałkę › po prawej.
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final content = Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: t.accentSoft, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: AppIcon(icon!, size: 20, color: t.accent),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (title != null) Expanded(child: Text(title!, style: text.titleLarge)),
                        ?trailing,
                      ],
                    ),
                  ),
                child,
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.chevron_right, size: 24, color: t.textMuted),
            ),
        ],
      ),
    );
    return Semantics(
      container: true,
      label: semanticsLabel,
      button: onTap != null,
      child: Material(
        color: backgroundColor ?? t.surface,
        elevation: 1.5,
        shadowColor: t.text.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor ?? t.border, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Separator wierszy w karcie: 1 dp `border`.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.tokens.border);
}
