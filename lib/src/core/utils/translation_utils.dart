import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Utility class for handling translations throughout the app
class TranslationUtils {
  /// Get translated text using Easy Localization
  /// 
  /// [context] - BuildContext required for accessing translations
  /// [key] - Translation key from the JSON file
  /// [args] - Optional list of arguments for string interpolation
  /// [namedArgs] - Optional map of named arguments for string interpolation
  /// [gender] - Optional gender for gender-specific translations
  /// 
  /// Returns the translated string or the key if translation is not found
  static String getTranslateText({
    required BuildContext context,
    required String key,
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) {
    return context.tr(key, args: args, namedArgs: namedArgs, gender: gender);
  }
}

/// Global function for easy access to translations
/// This is a convenience function that wraps TranslationUtils.getTranslateText
String getTranslateText({
  required BuildContext context,
  required String key,
  List<String>? args,
  Map<String, String>? namedArgs,
  String? gender,
}) {
  return TranslationUtils.getTranslateText(
    context: context,
    key: key,
    args: args,
    namedArgs: namedArgs,
    gender: gender,
  );
}
