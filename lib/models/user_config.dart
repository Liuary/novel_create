import 'dart:convert';

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
        annotationColorsHex: const [
          'FF5252',
          'FF9800',
          'FFEB3B',
          '4CAF50',
          '2196F3',
          '3F51B5',
          '9C27B0',
        ],
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
          UserConfig.defaults().annotationColorsHex,
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
