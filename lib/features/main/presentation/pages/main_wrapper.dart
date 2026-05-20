import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00); // نارنجی آرژان
    const Color bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // سایه بسیار محو و ظریف
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58, // ⬅️ ارتفاع بسیار جمع‌وجور و مینیمال
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMinimalCompactNavItem(
                  index: 0,
                  iconOutline: Icons.home_outlined,
                  iconFilled: Icons.home_rounded,
                  label: 'خانه',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _goBranch(0),
                  primaryColor: primaryColor,
                ),
                _buildMinimalCompactNavItem(
                  index: 1,
                  iconOutline: Icons.receipt_long_outlined,
                  iconFilled: Icons.receipt_long_rounded,
                  label: 'سفارشات',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _goBranch(1),
                  primaryColor: primaryColor,
                ),
                _buildMinimalCompactNavItem(
                  index: 2,
                  iconOutline: Icons.person_outline_rounded,
                  iconFilled: Icons.person_rounded,
                  label: 'پروفایل',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () => _goBranch(2),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎨 ویجت نویگیشن بار جمع‌وجور با انیمیشن ریز و روان
  // ====================================================================
  Widget _buildMinimalCompactNavItem({
    required int index,
    required IconData iconOutline,
    required IconData iconFilled,
    required String label,
    required int currentIndex,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1️⃣ انیمیشن تعویض آیکون (ظریف و نرم)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: isSelected
                    ? Icon(
                        iconFilled,
                        key: ValueKey<String>('filled_$index'),
                        color: primaryColor,
                        size: 25, // ⬅️ سایز ظریف‌تر در حالت فعال
                      )
                    : Icon(
                        iconOutline,
                        key: ValueKey<String>('outline_$index'),
                        color: Colors.grey.shade400,
                        size: 24, // ⬅️ سایز ظریف‌تر در حالت غیرفعال
                      ),
              ),

              // 2️⃣ انیمیشن باز شدن متن با ارتفاع کمتر برای جلوگیری از پرش زیاد
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: isSelected ? 16 : 0, // ⬅️ ارتفاع جمع‌وجورتر برای باز شدن متن
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2), // فاصله ریز
                    child: Text(
                      label,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10, // ⬅️ فونت مینیمال و شیک
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}