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

  // اللون التركوازي الموحد لكل الأقسام
  static const Color turquoise = Color(0xFF20C7B7);

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          height: 78,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE5E9EE),
              ),
            ),
          ),
          child: Row(
            children: [
              // الحساب
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  label: 'الحساب',
                  selected: selectedIndex == 3,
                  onTap: () => _navigate(context, 3),
                ),
              ),

              // التقدم
              Expanded(
                child: _NavItem(
                  icon: Icons.show_chart_rounded,
                  label: 'التقدم',
                  selected: selectedIndex == 2,
                  onTap: () => _navigate(context, 2),
                ),
              ),

              // الخطة
              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'الخطة',
                  selected: selectedIndex == 1,
                  onTap: () => _navigate(context, 1),
                ),
              ),

              // الرئيسية
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: selectedIndex == 0,
                  onTap: () => _navigate(context, 0),
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
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const turquoise = Color(0xFF20C7B7);

    return InkWell(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: selected
                ? turquoise.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: turquoise,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: turquoise,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
