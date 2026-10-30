import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ikony interfejsu z paczki marki (assets/icons, 24 × 24, kolor z `currentColor`).
enum AppIcons {
  today('dzis'),
  shopping('zakupy'),
  chores('obowiazki'),
  calendar('kalendarz'),
  notes('notatki'),
  budget('budzet'),
  add('dodaj'),
  notifications('powiadomienia'),
  reminder('przypomnienie'),
  onlyMe('tylko-ja'),
  settings('ustawienia'),
  qr('kod-qr');

  const AppIcons(this.file);

  final String file;

  String get asset => 'assets/icons/$file.svg';
}

/// Rysuje ikonę z paczki w podanym kolorze (domyślnie kolor ikon z motywu).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color});

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      icon.asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}
