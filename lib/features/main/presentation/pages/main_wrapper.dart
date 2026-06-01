import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:arjan_startup/core/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index, BuildContext context) {
    final storeType = _getStoreTypeFromIndex(index);
    if (storeType != null) {
      context.read<StoreProvider>().setStore(storeType);
    }
    
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  StoreType? _getStoreTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return StoreType.restaurant;
      case 1:
        return StoreType.supermarket;
      case 2:
        return StoreType.locations;
      case 3:
        return StoreType.profile;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: navigationShell,
      bottomNavigationBar: Consumer<StoreProvider>(
        builder: (context, storeProvider, _) {
          // ✅ دریافت رنگ بر اساس تب فعال
          final activeColor = _getColorForIndex(currentIndex, storeProvider);
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'رستوران',
                      iconOutline: Icons.restaurant_outlined,
                      iconFilled: Icons.restaurant_rounded,
                      isSelected: currentIndex == 0,
                      selectedColor: activeColor,
                      onTap: () => _goBranch(0, context),
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'سوپرمارکت',
                      iconOutline: Icons.store_outlined,
                      iconFilled: Icons.store_rounded,
                      isSelected: currentIndex == 1,
                      selectedColor: activeColor,
                      onTap: () => _goBranch(1, context),
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'سفارشات',
                      iconOutline: Icons.receipt_long_outlined,
                      iconFilled: Icons.receipt_long_rounded,
                      isSelected: currentIndex == 2,
                      selectedColor: activeColor,
                      onTap: () => _goBranch(2, context),
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'پروفایل',
                      iconOutline: Icons.person_outline_rounded,
                      iconFilled: Icons.person_rounded,
                      isSelected: currentIndex == 3,
                      selectedColor: activeColor,
                      onTap: () => _goBranch(3, context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ تابع برای تعیین رنگ بر اساس تب فعال
  Color _getColorForIndex(int index, StoreProvider storeProvider) {
    switch (index) {
      case 0:
        return StoreType.restaurant.primaryColor;
      case 1:
        return StoreType.supermarket.primaryColor;
      case 2:
        return StoreType.locations.primaryColor;
      case 3:
        return StoreType.profile.primaryColor;
      default:
        return storeProvider.currentStore.primaryColor;
    }
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData iconOutline,
    required IconData iconFilled,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    final Color itemColor = isSelected ? selectedColor : Colors.grey.shade400;
    
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
                        color: itemColor,
                        size: 25,
                      )
                    : Icon(
                        iconOutline,
                        key: ValueKey<String>('outline_$index'),
                        color: itemColor,
                        size: 24,
                      ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: isSelected ? 16 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: itemColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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