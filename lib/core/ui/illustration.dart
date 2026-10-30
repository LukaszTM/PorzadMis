import 'package:flutter/material.dart';

/// Ilustracje 3D z paczki marki (PNG z przezroczystością, `assets/images/3d`).
/// Mają stałe kolory we wszystkich motywach, jak sygnet misia.
enum Illustration {
  home('home'),
  shopping('shopping'),
  chores('chores'),
  calendar('calendar'),
  notes('notes'),
  budget('budget'),
  house('dom'),
  list('lista'),
  notebook('notatnik'),
  savings('oszczednosci'),
  plant('roslina'),
  dates('terminy'),
  bearHouse('mis-z-domem'),
  bearResting('mis-odpoczywa'),
  bearLogo('mis-logo');

  const Illustration(this.file);

  final String file;

  String get asset => 'assets/images/3d/$file.png';
}

/// Rysuje ilustrację w zadanej wysokości (kwadratowe PNG). [semanticsLabel] tylko, gdy obrazek
/// niesie treść; dekoracje są pomijane przez czytnik ekranu.
class IllustrationImage extends StatelessWidget {
  const IllustrationImage(this.illustration, {super.key, this.height = 96, this.semanticsLabel});

  final Illustration illustration;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: semanticsLabel != null,
      excludeSemantics: semanticsLabel == null,
      child: SizedBox(
        width: height,
        height: height,
        child: Image.asset(
          illustration.asset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          cacheHeight: (height * 3).round(),
        ),
      ),
    );
  }
}
