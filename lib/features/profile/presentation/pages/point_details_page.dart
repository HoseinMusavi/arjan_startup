import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/point_detail_dto.dart';

class PointDetailsPage extends StatefulWidget {
  const PointDetailsPage({super.key});

  @override
  State<PointDetailsPage> createState() => _PointDetailsPageState();
}

class _PointDetailsPageState extends State<PointDetailsPage> {
  late String _pointType;
  late String _pageTitle;
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    _pointType = extra?['pointType'] as String? ?? 'income_points';
    _pageTitle = extra?['title'] as String? ?? 'جزئیات کیف پول';

    debugPrint('📋 [PointDetailsPage] type: $_pointType, title: $_pageTitle');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _profileBloc.add(ProfilePointDetailsRequested(pointType: _pointType));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitle),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              debugPrint('❌ [PointDetailsPage] Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfilePointDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfilePointDetailsLoaded) {
              return _buildDetailsContent(context, state.details);
            }
            if (state is ProfileError) {
              return _buildErrorWidget(context, state.message);
            }
            return const Center(child: Text('داده‌ای وجود ندارد'));
          },
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
            'خطا در بارگذاری جزئیات',
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
              debugPrint('🔄 [PointDetailsPage] Retry');
              _profileBloc.add(ProfilePointDetailsRequested(pointType: _pointType));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, List<PointDetailDto> details) {
    debugPrint('📋 [PointDetailsPage] Rendering ${details.length} items');

    if (details.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'هیچ تراکنشی یافت نشد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final item = details[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.attach_money, color: Colors.green.shade700, size: 20),
            ),
            title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              item.date,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            trailing: Text(
              '${item.points} امتیاز',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        );
      },
    );
  }
}