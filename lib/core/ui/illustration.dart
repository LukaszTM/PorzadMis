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
  list('lista', cropTop: 0.16),
  notebook('notatnik'),
  savings('oszczednosci'),
  plant('roslina'),
  dates('terminy', cropTop: 0.16),
  bearHouse('mis-z-domem'),
  bearResting('mis-odpoczywa'),
  // Logo = miś z domkiem (plik 1254 px był za duży do APK).
  bearLogo('mis-z-domem');

  const Illustration(this.file, {this.cropTop = 0});

  final String file;

  /// Ułamek wysokości obcinany od góry (artefakty w pliku).
  final double cropTop;

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
        child: ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1 - illustration.cropTop,
            child: Image.asset(
              illustration.asset,
              width: height,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              cacheHeight: (height * 3).round(),
            ),
          ),
        ),
      ),
    );
  }
}
