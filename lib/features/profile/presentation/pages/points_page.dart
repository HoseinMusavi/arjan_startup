import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/point_summary_dto.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('💰 [PointsPage] initState');
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(const ProfilePointsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('کیف پول'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            debugPrint('🔄 [PointsPage] Pull to refresh');
            _profileBloc.add(const ProfilePointsRequested());
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                debugPrint('❌ [PointsPage] Error: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfilePointsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfilePointsLoaded) {
                return _buildPointsContent(context, state.points);
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
            'خطا در بارگذاری کیف پول',
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
              debugPrint('🔄 [PointsPage] Retry');
              _profileBloc.add(const ProfilePointsRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsContent(BuildContext context, List<PointSummaryDto> points) {
    debugPrint('💰 [PointsPage] Rendering ${points.length} items');

    final Map<String, Color> colorMap = {
      'income_points': Colors.green.shade600,
      'expenses_points': Colors.red.shade600,
      'expired_points': Colors.grey.shade600,
      'points_merchant': Colors.orange.shade600,
    };
    final Map<String, IconData> iconMap = {
      'income_points': Icons.arrow_upward,
      'expenses_points': Icons.arrow_downward,
      'expired_points': Icons.timer_off,
      'points_merchant': Icons.storefront,
    };
    final Map<String, String> titleMap = {
      'income_points': 'درآمد کیف پول',
      'expenses_points': 'هزینه‌ها',
      'expired_points': 'امتیازات منقضی شده',
      'points_merchant': 'امتیازات فروشگاه',
    };

    if (points.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'کیف پول شما خالی است',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'با ثبت نام و خرید، امتیاز دریافت کنید.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: points.length,
            itemBuilder: (context, index) {
              final item = points[index];
              final color = colorMap[item.pointType] ?? Colors.blue;
              final icon = iconMap[item.pointType] ?? Icons.attach_money;
              final title = titleMap[item.pointType] ?? item.label;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    debugPrint('💰 [PointsPage] Navigate to details: ${item.pointType}');
                    context.push(
                      '/profile/points/details',
                      extra: {
                        'pointType': item.pointType,
                        'title': title,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.value.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '💡 نکات مهم',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• امتیازات شما از طریق ثبت نام، خرید و فعالیت‌های ویژه کسب می‌شوند.\n'
                  '• امتیازات منقضی شده قابل بازگشت نیستند.\n'
                  '• برای مشاهده جزئیات هر بخش، روی کارت مربوطه کلیک کنید.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}