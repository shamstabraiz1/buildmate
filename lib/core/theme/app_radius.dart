import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const none = 0.0;
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 24.0;

  static const card = md;
  static const button = md;
  static const input = md;
  static const dialog = lg;
  static const bottomSheet = xl;
  static const snackbar = sm;

  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const buttonBorder = BorderRadius.all(Radius.circular(button));
  static const inputBorder = BorderRadius.all(Radius.circular(input));
  static const dialogBorder = BorderRadius.all(Radius.circular(dialog));
  static const snackbarBorder = BorderRadius.all(Radius.circular(snackbar));

  static const bottomSheetBorder = BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
}
