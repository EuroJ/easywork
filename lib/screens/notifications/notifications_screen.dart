import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'ວຽກງານໃໝ່ໄດ້ຮັບມອບໝາຍ',
      message: 'ທ່ານໄດ້ຮັບມອບໝາຍວຽກງານ "ອັບເດດລະບົບຈັດການ"',
      type: NotificationType.task,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'ວຽກງານໃກ້ໝົດກຳໜົດ',
      message: 'ວຽກງານ "ລາຍງານປະຈໍາເດືອນ" ໃກ້ໝົດກຳໜົດແລ້ວ',
      type: NotificationType.deadline,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'ຄຳເຫັນໃໝ່',
      message: 'ມີຄຳເຫັນໃໝ່ໃນວຽກງານ "ປັບປຸງ UI"',
      type: NotificationType.comment,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'ວຽກງານສຳເລັດ',
      message: 'ວຽກງານ "ສ້າງຖານຂໍ້ມູນ" ໄດ້ສຳເລັດແລ້ວ',
      type: NotificationType.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.notifications,
                style: AppTextStyles.h4,
              ),
              if (unreadCount > 0)
                Text(
                  '$unreadCount ຄຳແຈ້ງເຕືອນໃໝ່',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'ອ່ານທັງໝົດ',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.surface : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildNotificationIcon(notification.type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.task:
        icon = Icons.assignment;
        color = AppColors.info;
        break;
      case NotificationType.deadline:
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        color = AppColors.secondary;
        break;
      case NotificationType.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'ບໍ່ມີການແຈ້ງເຕືອນ',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ການແຈ້ງເຕືອນຈະສະແດງຢູ່ນີ້',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  // ✅ ปรับ date formatter เพื่อหลีกเลี่ยง LocaleDataException
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'ບໍ່ດົນມານີ້';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ນາທີກ່ອນ';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ຊົ່ວໂມງກ່ອນ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ມື້ກ່ອນ';
    } else {
      try {
        return DateFormat('dd/MM/yyyy').format(timestamp);
      } catch (e) {
        // Fallback ถ้า locale ไม่รองรับ
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    }
  }
}

enum NotificationType { task, deadline, comment, completed }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}