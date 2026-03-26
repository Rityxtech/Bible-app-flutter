import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bible_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      if (kDebugMode) print('Timezone init error: $e. Falling back to UTC.');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _initialized = true;
  }

  /// Requests notification permission. Returns true if granted.
  Future<bool> requestPermissions() async {
    // On Android 13+ we need POST_NOTIFICATIONS at runtime
    final status = await Permission.notification.request();
    if (status.isGranted) return true;
    if (kDebugMode) print('Notification permission denied: $status');
    return false;
  }

  /// Cancels all scheduled notifications and re-schedules one per day for the
  /// next [days] days at 6:00 AM local time, each with a randomly picked verse.
  Future<void> scheduleDailyVerses(BibleProvider provider, {int days = 30}) async {
    if (!_initialized) await init();

    // Ensure books are loaded
    if (provider.books.isEmpty) {
      if (kDebugMode) print('scheduleDailyVerses: books not loaded yet, skipping.');
      return;
    }

    await _plugin.cancelAll();

    final random = Random();
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < days; i++) {
      // Always start from today's 6 AM then add i days — safe date math
      final target = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        6,
        0,
      ).add(Duration(days: i));

      // Skip if this scheduled time has already passed today
      if (target.isBefore(now)) continue;

      // Pick a random verse
      final book = provider.books[random.nextInt(provider.books.length)];
      final chapter = book.chapters[random.nextInt(book.chapters.length)];
      final verse = chapter.verses[random.nextInt(chapter.verses.length)];

      final body = '${book.name} ${chapter.chapter}:${verse.verse} — ${verse.text}';

      try {
        await _plugin.zonedSchedule(
          i, // unique ID per day slot
          'Daily Bible Verse',
          body,
          target,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_verse_channel',
              'Daily Verses',
              channelDescription: 'Daily verse notifications at 6 AM',
              importance: Importance.max,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(body),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        if (kDebugMode) print('Could not schedule notification for day $i: $e');
      }
    }

    if (kDebugMode) print('Scheduled daily verse notifications for up to $days days.');
  }

  Future<void> cancelDailyVerses() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
