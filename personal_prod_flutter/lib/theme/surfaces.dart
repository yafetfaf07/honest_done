import 'package:flutter/material.dart';

abstract final class AppRadii {
  const AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

abstract final class AppShadows {
  const AppShadows._();

  static List<BoxShadow> cardBorder(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const [BoxShadow(color: Color(0x14FFFFFF), spreadRadius: 1)];
    }
    return const [
      BoxShadow(color: Color(0x0F000000), spreadRadius: 1),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 2,
        spreadRadius: -1,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ];
  }
}