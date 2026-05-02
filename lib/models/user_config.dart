import 'dart:convert';
import 'annotation.dart' as annotation;

class UserConfig {
  int autoSaveIntervalSeconds;
  int autoSaveNotificationDurationSeconds;
  List<String> annotationColorsHex;

  UserConfig({
    required this.autoSaveIntervalSeconds,
    required this.autoSaveNotificationDurationSeconds,
    required this.annotationColorsHex,
  });

  factory UserConfig.defaults() => UserConfig(
        autoSaveIntervalSeconds: 10,
        autoSaveNotificationDurationSeconds: 2,
        annotationColorsHex: annotation.annotationColorsHex,
      );

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      autoSaveIntervalSeconds:
          json['autoSaveIntervalSeconds'] as int? ?? 10,
      autoSaveNotificationDurationSeconds:
          json['autoSaveNotificationDurationSeconds'] as int? ?? 2,
      annotationColorsHex: (json['annotationColorsHex'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          annotation.annotationColorsHex,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoSaveIntervalSeconds': autoSaveIntervalSeconds,
        'autoSaveNotificationDurationSeconds':
            autoSaveNotificationDurationSeconds,
        'annotationColorsHex': annotationColorsHex,
      };

  String toJsonString() => jsonEncode(toJson());
}
