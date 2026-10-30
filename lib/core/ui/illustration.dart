import 'package:flutter/material.dart';

/// Ilustracje 3D z paczki marki. Część leży na arkuszach: [rect] to wycinek w ułamkach
/// szerokości i wysokości obrazu (0–1), więc nie trzeba ciąć plików ręcznie.
enum Illustration {
  bearHouse('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.00, 0.06, 0.36, 0.52), 1448, 1086),
  bearSleeping('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.36, 0.14, 0.36, 0.44), 1448, 1086),
  house('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.72, 0.20, 0.28, 0.36), 1448, 1086),
  plant('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.00, 0.60, 0.19, 0.36), 1448, 1086),
  coins('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.17, 0.60, 0.21, 0.36), 1448, 1086),
  clipboard('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.38, 0.60, 0.20, 0.36), 1448, 1086),
  calendar('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.58, 0.60, 0.21, 0.36), 1448, 1086),
  note('assets/images/mis-arkusz.webp', Rect.fromLTWH(0.79, 0.60, 0.21, 0.36), 1448, 1086),
  bearHead('assets/images/mis-glowa.webp', Rect.fromLTWH(0, 0, 1, 1), 1254, 1254),
  iconHouse('assets/images/ikony-3d.webp', Rect.fromLTWH(0.00, 0.0, 0.34, 0.5), 2000, 667),
  iconBasket('assets/images/ikony-3d.webp', Rect.fromLTWH(0.34, 0.0, 0.32, 0.5), 2000, 667),
  iconClipboard('assets/images/ikony-3d.webp', Rect.fromLTWH(0.66, 0.0, 0.34, 0.5), 2000, 667),
  iconCalendar('assets/images/ikony-3d.webp', Rect.fromLTWH(0.00, 0.5, 0.34, 0.5), 2000, 667),
  iconNote('assets/images/ikony-3d.webp', Rect.fromLTWH(0.34, 0.5, 0.32, 0.5), 2000, 667),
  iconCoins('assets/images/ikony-3d.webp', Rect.fromLTWH(0.66, 0.5, 0.34, 0.5), 2000, 667);

  const Illustration(this.asset, this.rect, this.imageWidth, this.imageHeight);

  final String asset;
  final Rect rect;
  final double imageWidth;
  final double imageHeight;
}

/// Rysuje ilustrację (lub jej wycinek z arkusza) w zadanym rozmiarze, zachowując proporcje.
class IllustrationImage extends StatelessWidget {
  const IllustrationImage(this.illustration, {super.key, this.height = 96, this.width, this.semanticsLabel});

  final Illustration illustration;
  final double height;
  final double? width;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final i = illustration;
    final cropW = i.imageWidth * i.rect.width;
    final cropH = i.imageHeight * i.rect.height;
    // Align z widthFactor/heightFactor przycina obraz do wycinka; alignment wybiera, który fragment.
    final ax = i.rect.width >= 1 ? 0.0 : (i.rect.left / (1 - i.rect.width)) * 2 - 1;
    final ay = i.rect.height >= 1 ? 0.0 : (i.rect.top / (1 - i.rect.height)) * 2 - 1;
    return Semantics(
      label: semanticsLabel,
      image: semanticsLabel != null,
      excludeSemantics: semanticsLabel == null,
      child: SizedBox(
        height: height,
        width: width ?? height * (cropW / cropH),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: cropW,
            height: cropH,
            child: ClipRect(
              child: Align(
                alignment: Alignment(ax, ay),
                widthFactor: i.rect.width,
                heightFactor: i.rect.height,
                child: Image.asset(
                  i.asset,
                  width: i.imageWidth,
                  height: i.imageHeight,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
