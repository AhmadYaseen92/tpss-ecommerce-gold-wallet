import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';

class NotificationModel {
  final String title;
  final String description;
  final DateTime dateTime;
  final Icon icon;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.icon,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      title: title,
      description: description,
      dateTime: dateTime,
      icon: icon,
      isRead: isRead ?? this.isRead,
    );
  }
}

List<NotificationModel> todayNotifications = [
  NotificationModel(
    title: "Gold Price Surge",
    description:
        "Gold prices have hit a new daily high of \$2,145. Check your portfolio value now.",
    dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    icon: const Icon(Icons.trending_up, color: AppColors.amber),
  ),
  NotificationModel(
    title: "Deposit Confirmed",
    description:
        "Your transfer of \$2,000.00 has been successfully credited to your wallet.",
    dateTime: DateTime.now().subtract(const Duration(hours: 5)),
    icon: const Icon(Icons.account_balance, color: AppColors.teal),
  ),
  NotificationModel(
    title: "Purchase Complete",
    description:
        "You successfully purchased 2.5g of gold. View your order details.",
    dateTime: DateTime.now().subtract(const Duration(hours: 8)),
    icon: const Icon(Icons.check_circle, color: AppColors.blue),
  ),
  
];

List<NotificationModel> weekNotifications = [
  NotificationModel(
    title: "Security Alert",
    description:
        "New login attempt detected from Firefox on Windows. Was this you?",
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
    icon: const Icon(Icons.shield_outlined, color: AppColors.grey),
  ),
  NotificationModel(
    title: "Weekend Promo",
    description:
        "Zero fees on silver purchases this weekend only! Don't miss out.",
    dateTime: DateTime.now().subtract(const Duration(days: 3)),
    icon: const Icon(Icons.percent, color: AppColors.grey),
  ),
  NotificationModel(
    title: "Balance Update",
    description:
        "Your wallet balance has been updated. Current balance: \$15,234.50",
    dateTime: DateTime.now().subtract(const Duration(days: 4)),
    icon: const Icon(Icons.info_outline, color: AppColors.grey),
  ),
  NotificationModel(
    title: "Security Alert",
    description:
        "New login attempt detected from Firefox on Windows. Was this you?",
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
    icon: const Icon(Icons.shield_outlined, color: AppColors.grey),
  ),
  NotificationModel(
    title: "Security Alert",
    description:
        "New login attempt detected from Firefox on Windows. Was this you?",
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
    icon: const Icon(Icons.shield_outlined, color: AppColors.grey),
  ),
];

List<NotificationModel> dummyNotifications = [];