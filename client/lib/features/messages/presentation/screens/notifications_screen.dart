import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/notifications_repository.dart';
import '../../../../core/globals.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationsRepository();
  bool _isMarkingAll = false;

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    await _repository.markAllAsRead();
    if (mounted) {
      setState(() => _isMarkingAll = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationEntity>>(
      stream: _repository.getNotificationsStream(),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final hasUnread = notifications.any((n) => !n.isRead);

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
                    _buildHeader(context, notifications, hasUnread),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData
                          ? const Center(child: CircularProgressIndicator(color: AppColors.mutedGold))
                          : notifications.isEmpty
                              ? _buildEmptyState()
                              : _buildNotificationsList(notifications),
                    ),
                  ],
                ),
              ),
              const SmartDashboardPanel(currentRoute: '/notifications'),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context, List<NotificationEntity> notifications, bool hasUnread) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          FadeInDown(
            child: Text(
              AppLocalizations.of(context)!.notifications,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Spacer(),
          if (hasUnread)
            _isMarkingAll 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mutedGold))
              : TextButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all, color: AppColors.mutedGold, size: 16),
                  label: Text(
                    AppLocalizations.of(context)!.markAllRead,
                    style: const TextStyle(
                      color: AppColors.mutedGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
            Text(
              AppLocalizations.of(context)!.allCaughtUp,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noNewNotifications,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification, index);
      },
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification, int index) {
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
      case 'WELCOME':
        icon = Icons.auto_awesome_outlined;
        iconColor = Colors.purpleAccent;
        break;
      case 'FAVORITE':
        icon = Icons.favorite_border_rounded;
        iconColor = AppColors.brickRed;
        break;
      case 'EFFICIENCY':
        icon = Icons.bolt_rounded;
        iconColor = Colors.amberAccent;
        break;
      case 'SYSTEM':
        icon = Icons.settings_suggest_outlined;
        iconColor = Colors.grey;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = AppColors.mutedGold;
    }

    return FadeInLeft(
      delay: Duration(milliseconds: 50 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
          onDismissed: (_) {
            _repository.deleteNotification(notification.id);
          },
          child: InkWell(
            onTap: () async {
              if (!notification.isRead) {
                await _repository.markAsRead(notification.id);
              }
              if (mounted && notification.route != null) {
                context.push(notification.route!);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(16),
              opacity: notification.isRead ? 0.08 : 0.22,
              borderColor: notification.isRead ? Colors.white10 : AppColors.mutedGold.withOpacity(0.3),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      if (!notification.isRead)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.mutedGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.structuralBrown, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              _getTimeAgo(notification.createdAt),
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(notification.isRead ? 0.6 : 0.9),
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
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
