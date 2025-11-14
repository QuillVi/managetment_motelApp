// lib/data/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
// THÊM IMPORT NÀY
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/detail_bill/detail_bill.dart';
import 'package:motelapp/router/app_router.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // 1. TẠO INSTANCE CỦA LOCAL NOTIFICATIONS
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AppRouter _appRouter = getIt<AppRouter>();

  // 2. TẠO MỘT "CHANNEL" CHO ANDROID (Bắt buộc)
  // Kênh này sẽ dùng để hiển thị thông báo khi app đang mở
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // ID (đặt tên bất kỳ)
    'High Importance Notifications', // Tên
    description: 'Kênh này dùng cho các thông báo quan trọng.', // Mô tả
    importance: Importance.high, // Đặt mức độ quan trọng cao
    playSound: true,
  );

  // ⭐️ THÊM MỚI: Hàm xử lý điều hướng tập trung
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? screen = data['screen'];
    final String? billId = data['billId'];

    if (screen == 'BillDetails' && billId != null) {
      print('Điều hướng đến màn hình chi tiết hóa đơn: $billId');
      try {
        final id = int.tryParse(billId) ?? 0;
        // Dùng router đã inject để điều hướng
        _appRouter.push(DetailBill(idHoaDon: id));
      } catch (e) {
        print("Lỗi điều hướng từ thông báo: $e");
      }
    }
  }

  Future<void> initNotifications() async {
    // Yêu cầu quyền (cho iOS)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. KHỞI TẠO LOCAL NOTIFICATIONS
    // Cài đặt cho Android (dùng icon mặc định)
    // Bạn có thể đổi '@mipmap/ic_launcher' thành icon thông báo của riêng bạn
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cài đặt cho iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Khởi tạo plugin
    await _localNotifications.initialize(
      initSettings,

      // ⭐️ THÊM VÀO: Xử lý khi bấm vào thông báo (lúc app đang mở)
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Chỗ này cần phân tích payload, nhưng logic server của bạn
        // đã gửi 'data' nên chúng ta tập trung vào onMessageOpenedApp
        print('Bấm vào thông báo (foreground): ${response.payload}');
      },
    );

    // 4. TẠO CHANNEL TRÊN THIẾT BỊ (cho Android)
    // Báo cho plugin Android biết về channel chúng ta đã tạo
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // 5. CẬP NHẬT HÀM LẮNG NGHE (onMessage)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');

      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      // Nếu có thông báo
      if (notification != null) {
        print('Notification Title: ${notification.title}');
        print('Notification Body: ${notification.body}');

        // DÙNG LOCAL NOTIFICATIONS ĐỂ HIỂN THỊ
        _localNotifications.show(
          notification.hashCode, // ID duy nhất cho thông báo
          notification.title, // Tiêu đề
          notification.body, // Nội dung
          NotificationDetails(
            // Cài đặt chi tiết cho Android
            android: AndroidNotificationDetails(
              _channel.id, // Dùng channel ID đã tạo ở trên
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher', // Icon
              playSound: true,
              importance: Importance.high,
            ),
            // Cài đặt chi tiết cho iOS
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // Lắng nghe khi bấm vào thông báo (mở app từ background)
    // 6. ⭐️ CẬP NHẬT: Lắng nghe khi bấm (mở app từ Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! (Background)');
      // Gọi hàm điều hướng
      _handleNotificationNavigation(message.data);
    });

    // 7. ⭐️ THÊM MỚI: Xử lý khi bấm (mở app từ Terminated)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('Message clicked! (Terminated)');
      // Gọi hàm điều hướng
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("My FCM Token: $token");
      return token;
    } catch (e) {
      print("Failed to get FCM token: $e");
      return null;
    }
  }
}
