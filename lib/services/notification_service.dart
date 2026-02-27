import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Show an instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aidconnect_channel',
      'AidConnect Notifications',
      channelDescription: 'Notifications for AidConnect app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a notification for later
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aidconnect_scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for AidConnect',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap based on payload
    final payload = response.payload;
    if (payload != null) {
      // Navigate based on payload
      // This will be handled by the app's navigation system
    }
  }

  /// Show notification for case approval
  Future<void> showCaseApprovedNotification({
    required int caseId,
    required String caseTitle,
  }) async {
    await showNotification(
      id: caseId,
      title: 'تم قبول حالتك',
      body: 'تمت الموافقة على حالة "$caseTitle" بنجاح.',
      payload: 'case_approved:$caseId',
    );
  }

  /// Show notification for case rejection
  Future<void> showCaseRejectedNotification({
    required int caseId,
    required String caseTitle,
    String? reason,
  }) async {
    await showNotification(
      id: caseId,
      title: 'حالة مرفوضة',
      body: reason != null
          ? 'تم رفض حالة "$caseTitle". السبب: $reason'
          : 'تم رفض حالة "$caseTitle".',
      payload: 'case_rejected:$caseId',
    );
  }

  /// Show notification for organization approval
  Future<void> showOrganizationApprovedNotification({
    required String organizationName,
  }) async {
    await showNotification(
      id: 1000,
      title: 'تمت الموافقة على المنظمة',
      body: 'تمت الموافقة على طلب انضمام منظمتك "$organizationName" بنجاح.',
      payload: 'org_approved',
    );
  }

  /// Show notification for volunteer request accepted
  Future<void> showVolunteerRequestAcceptedNotification({
    required int caseId,
    required String caseTitle,
  }) async {
    await showNotification(
      id: caseId + 5000,
      title: 'تم قبول طلب التطوع',
      body: 'تم قبول طلبك للتطوع في حالة "$caseTitle".',
      payload: 'volunteer_accepted:$caseId',
    );
  }

  /// Show notification for volunteer request rejected
  Future<void> showVolunteerRequestRejectedNotification({
    required int caseId,
    required String caseTitle,
    String? reason,
  }) async {
    await showNotification(
      id: caseId + 5000,
      title: 'طلب تطوع مرفوض',
      body: reason != null
          ? 'تم رفض طلبك للتطوع في حالة "$caseTitle". السبب: $reason'
          : 'تم رفض طلبك للتطوع في حالة "$caseTitle".',
      payload: 'volunteer_rejected:$caseId',
    );
  }
}
