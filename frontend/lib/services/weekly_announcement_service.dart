import 'package:shared_preferences/shared_preferences.dart';

class WeeklyAnnouncementService {
  static const int currentAnnouncementVersion = 1;
  static const String _lastShownVersionKey =
      'weekly_announcement_last_shown_version';

  Future<bool> shouldShowCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownVersion = prefs.getInt(_lastShownVersionKey) ?? 0;
    return lastShownVersion < currentAnnouncementVersion;
  }

  Future<void> markCurrentVersionShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastShownVersionKey, currentAnnouncementVersion);
  }
}
