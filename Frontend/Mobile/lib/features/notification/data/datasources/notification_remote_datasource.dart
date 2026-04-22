import 'package:dio/dio.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<NotificationRemoteModel>> getNotifications({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _dio.post(
      '/notifications/my/search',
      data: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>?;
    final items = (data?['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => NotificationRemoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.put(
      '/notifications/my/read',
      data: {
        'notificationId': notificationId,
      },
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/my/unread-count');
    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>?;
    return (data?['unreadCount'] as num?)?.toInt() ?? 0;
  }

}

class NotificationRemoteModel {
  NotificationRemoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAtUtc,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAtUtc;

  factory NotificationRemoteModel.fromJson(Map<String, dynamic> json) {
    return NotificationRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      isRead: (json['isRead'] ?? false) as bool,
      createdAtUtc:
          DateTime.tryParse((json['createdAtUtc'] ?? '').toString()) ?? DateTime.now().toUtc(),
    );
  }
}
