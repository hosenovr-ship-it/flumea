import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'plan_screen.dart';
import 'progress_screen.dart';
import 'account_screen.dart';

class FlumeaBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const FlumeaBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const PlanScreen();
        break;
      case 2:
        page = const ProgressScreen();
        break;
      case 3:
        page = const AccountScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const turquoise = Color(0xFF20C7B7);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Keep the existing light design and make the navigation
    // match the dark theme when dark mode is enabled.
    final navigationBackground =
        isDark ? const Color(0xFF111217) : Colors.white;

    final topBorderColor =
        isDark ? const Color(0xFF2B3440) : const Color(0xFFEFE5EE);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: navigationBackground,
            border: Border(
              top: BorderSide(
                color: topBorderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 1 — الرئيسية
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'الرئيسية',
                  selected: selectedIndex == 0,
                  color: turquoise,
                  onTap: () => _navigate(context, 0),
                ),
              ),

              // 2 — الخطة
              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  label: 'الخطة',
                  selected: selectedIndex == 1,
                  color: turquoise,
                  onTap: () => _navigate(context, 1),
                ),
              ),

              // 3 — التقدم
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'التقدم',
                  selected: selectedIndex == 2,
                  color: turquoise,
                  onTap: () => _navigate(context, 2),
                ),
              ),

              // 4 — الحساب
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'الحساب',
                  selected: selectedIndex == 3,
                  color: turquoise,
                  onTap: () => _navigate(context, 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
