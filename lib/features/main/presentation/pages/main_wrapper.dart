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
        return null;
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
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 65,
                child: Row(
                  children: [
                    _buildNavItem(
                      label: 'رستوران',
                      icon: Icons.lunch_dining_rounded,
                      isSelected: currentIndex == 0,
                      selectedColor: const Color(0xFFFF7A00),
                      onTap: () => _goBranch(0, context),
                    ),
                    _buildNavItem(
                      label: 'سوپرمارکت',
                      icon: Icons.local_grocery_store_rounded,
                      isSelected: currentIndex == 1,
                      selectedColor: Colors.teal,
                      onTap: () => _goBranch(1, context),
                    ),
                    _buildNavItem(
                      label: 'سفارشات',
                      icon: Icons.receipt_long_rounded,
                      isSelected: currentIndex == 2,
                      selectedColor: const Color(0xFFFF7A00),
                      onTap: () => _goBranch(2, context),
                    ),
                    _buildNavItem(
                      label: 'پروفایل',
                      icon: Icons.account_circle_rounded,
                      isSelected: currentIndex == 3,
                      selectedColor: const Color(0xFFFF7A00),
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

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: isSelected ? 26 : 0,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.1 : 1,
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? selectedColor
                        : Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? selectedColor
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}