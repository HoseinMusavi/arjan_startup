import 'package:arjan_startup/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_bloc.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_event.dart';
import 'package:arjan_startup/features/orders/presentation/bloc/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/config/theme/app_theme.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final String? orderStatus; // اضافه شد - وضعیت سفارش از صفحه قبل

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    this.orderStatus,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> with SingleTickerProviderStateMixin {
  final OrderBloc _orderBloc = getIt<OrderBloc>();
  late AnimationController _animationController;
  
  // مرحله فعلی (از وضعیت سفارش محاسبه می‌شود)
  int _currentStep = 0;

  // مراحل سفارش
  final List<TrackingStep> _steps = const [
    TrackingStep(
      id: 0,
      title: 'ثبت سفارش',
      icon: Icons.receipt_outlined,
      description: 'سفارش شما ثبت شد',
    ),
    TrackingStep(
      id: 1,
      title: 'تأیید فروشگاه',
      icon: Icons.store_outlined,
      description: 'فروشگاه سفارش را تأیید کرد',
    ),
    TrackingStep(
      id: 2,
      title: 'آماده سازی',
      icon: Icons.kitchen_outlined,
      description: 'سفارش در حال آماده سازی',
    ),
    TrackingStep(
      id: 3,
      title: 'ارسال توسط پیک',
      icon: Icons.delivery_dining_outlined,
      description: 'سفارش به پیک تحویل شد',
    ),
    TrackingStep(
      id: 4,
      title: 'تحویل نهایی',
      icon: Icons.check_circle_outline,
      description: 'سفارش تحویل داده شد',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    
    // اگر وضعیت از قبل داریم، مرحله را محاسبه کن
    if (widget.orderStatus != null) {
      _currentStep = getStepFromStatus(widget.orderStatus!);
    }
    
    debugPrint('📍 [OrderTrackingPage] بررسی پیگیری سفارش: ${widget.orderId}');
    _orderBloc.add(CheckTrackEvent(
      orderId: widget.orderId,
      lat: 30.5882768,
      lng: 50.2575974,
    ));
  }

  // ✅ متد تبدیل وضعیت به مرحله - که گفتیم
  int getStepFromStatus(String status) {
    if (status == 'انتظار' || status == 'pending') return 0;
    if (status == 'در حال پردازش' || status == 'processing') return 1;
    if (status == 'آماده سازی' || status == 'preparing') return 2;
    if (status == 'ارسال' || status == 'shipped') return 3;
    if (status == 'تکمیل شده' || status == 'completed') return 4;
    return 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<OrderBloc, OrderState>(
        bloc: _orderBloc,
        listener: (context, state) {
          if (state.status == OrderStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          
          // اگر جزییات سفارش آماده شد، وضعیت را از آن استخراج کن
          if (state.orderDetail != null && widget.orderStatus == null) {
            final statusItem = state.orderDetail!.infoItems.firstWhere(
              (item) => item.label == 'وضعیت',
              orElse: () => const OrderInfoItemEntity(label: '', value: ''),
            );
            if (statusItem.value.isNotEmpty) {
              setState(() {
                _currentStep = getStepFromStatus(statusItem.value);
              });
            }
          }
        },
        builder: (context, state) {
          if (state.status == OrderStatus.loading && state.orderDetail == null) {
            return _buildShimmerLoading();
          }

          return FadeTransition(
            opacity: _animationController,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // هدر اطلاعات سفارش
                  _buildOrderHeader(),
                  const SizedBox(height: 24),
                  
                  // تایم‌لاین افقی
                  _buildHorizontalTimeline(),
                  const SizedBox(height: 32),
                  
                  // مرحله فعلی (توضیحات کامل)
                  _buildCurrentStepCard(),
                  const SizedBox(height: 16),
                  
                  // اطلاعات پیگیری
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  
                  // کارت کمک
                  _buildHelpCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            'پیگیری سفارش',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '#${widget.orderId}',
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    final step = _steps[_currentStep.clamp(0, _steps.length - 1)];
    final progress = ((_currentStep + 1) / _steps.length) * 100;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وضعیت فعلی',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              color: Colors.white,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تایم‌لاین افقی با خطوط متصل
  Widget _buildHorizontalTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= _currentStep;
            final isCurrent = index == _currentStep;
            
            return Row(
              children: [
                // دایره مرحله
                _buildTimelineNode(
                  step: step,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                ),
                // خط اتصال (به جز آخرین مرحله)
                if (index != _steps.length - 1)
                  _buildTimelineLine(isCompleted: isCompleted),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimelineNode({
    required TrackingStep step,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Column(
        children: [
          // دایره
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCompleted
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryLight,
                      ],
                    )
                  : null,
              color: isCompleted ? null : (isCurrent ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.dividerColor),
              border: isCurrent && !isCompleted
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                  : Icon(
                      step.icon,
                      color: isCurrent ? AppTheme.primaryColor : AppTheme.textHint,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // عنوان مرحله
          Text(
            step.title,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCompleted || isCurrent ? AppTheme.primaryColor : AppTheme.textHint,
            ),
          ),
          const SizedBox(height: 4),
          // توضیح کوتاه (اختیاری)
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'مرحله جاری',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 8,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine({required bool isCompleted}) {
    return Container(
      width: 50,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryLight,
                ],
              )
            : null,
        color: isCompleted ? null : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCurrentStepCard() {
    final step = _steps[_currentStep.clamp(0, _steps.length - 1)];
    final nextStep = _currentStep + 1 < _steps.length ? _steps[_currentStep + 1] : null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (nextStep != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.textHint),
                const SizedBox(width: 8),
                Text(
                  'مرحله بعدی: ${nextStep.title}',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text(
                'اطلاعات پیگیری',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('شماره سفارش', '#${widget.orderId}'),
          const SizedBox(height: 12),
          _buildInfoRow('وضعیت', _steps[_currentStep].title),
          const SizedBox(height: 12),
          _buildInfoRow('تاریخ ثبت', _getCurrentDate()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: باز کردن صفحه پشتیبانی یا تماس
        },
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        child: const Row(
          children: [
            Icon(Icons.support_agent, size: 28, color: AppTheme.primaryColor),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نیاز به کمک دارید؟',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'با پشتیبانی تماس بگیرید',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final persianYear = 1404; // تقریبی
    return '$persianYear/${now.month}/${now.day}';
  }
}

// مدل مرحله پیگیری
class TrackingStep {
  final int id;
  final String title;
  final IconData icon;
  final String description;

  const TrackingStep({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}