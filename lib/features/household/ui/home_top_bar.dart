import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../data/household_repository.dart';

/// Pasek górny ekranów głównych (makieta 2026): domek + nazwa domu, po prawej przycisk motywów.
class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final name = ref.watch(householdProvider).value?.name;
    return Row(
      children: [
        const SizedBox(width: 24, height: 24, child: IllustrationImage(Illustration.house, height: 24)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            (name == null || name.isEmpty) ? l.homeHouseholdFallback : name,
            style: text.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Semantics(
          button: true,
          label: l.themesButton,
          excludeSemantics: true,
          child: Material(
            color: t.surface,
            elevation: 1,
            shadowColor: t.text.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: t.border)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/settings/appearance'),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.auto_awesome_outlined, size: 22, color: t.text),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
