import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/notification_dto.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('🔔 [NotificationsPage] initState');
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(const ProfileNotificationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اعلان‌ها'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          actions: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {
                debugPrint('🔔 [NotificationsPage] Mark all as read');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('همه اعلان‌ها خوانده شدند!')),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            debugPrint('🔄 [NotificationsPage] Pull to refresh');
            _profileBloc.add(const ProfileNotificationsRequested());
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                debugPrint('❌ [NotificationsPage] Error: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileNotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfileNotificationsLoaded) {
                return _buildNotificationsContent(context, state.notifications);
              }
              if (state is ProfileError) {
                return _buildErrorWidget(context, state.message);
              }
              return const Center(child: Text('داده‌ای وجود ندارد'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری اعلان‌ها',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔄 [NotificationsPage] Retry');
              _profileBloc.add(const ProfileNotificationsRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent(BuildContext context, List<NotificationDto> notifications) {
    debugPrint('🔔 [NotificationsPage] Rendering ${notifications.length} items');

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'هیچ اعلانی وجود ندارد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'وقتی اعلان جدیدی دریافت کنید، اینجا نمایش داده می‌شود.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
                size: 22,
              ),
            ),
            title: Text(
              notification.pushTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              notification.dateCreated,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            trailing: const Icon(
              Icons.expand_more,
              color: Colors.grey,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  notification.pushMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}