import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/notifications_repository.dart';
import '../../../../core/globals.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationsRepository();
  List<NotificationEntity> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await _repository.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await _repository.markAllAsRead();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: kIsWeb
                ? Container(color: AppColors.alabaster)
                : AnimatedMeshGradient(
                    colors: [
                      AppColors.structuralBrown,
                      const Color(0xFF5D4037),
                      AppColors.mutedGold.withOpacity(0.4),
                      AppColors.structuralBrown,
                    ],
                    options: AnimatedMeshGradientOptions(speed: 2),
                  ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.mutedGold))
                      : _notifications.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => rootScaffoldKey.currentState?.openDrawer(),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          FadeInDown(
            child: Text(
              "Notifications",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Spacer(),
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                "MARK ALL READ",
                style: TextStyle(
                  color: AppColors.mutedGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(100),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "All caught up!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You don't have any new notifications.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'MESSAGE':
        icon = Icons.chat_bubble_outline;
        iconColor = Colors.blueAccent;
        break;
      case 'FINANCIAL':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = Colors.greenAccent;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = AppColors.mutedGold;
    }

    return FadeInLeft(
      delay: Duration(milliseconds: 50 * _notifications.indexOf(notification)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          opacity: notification.isRead ? 0.1 : 0.25,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat.jm().format(notification.createdAt),
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
