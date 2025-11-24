import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 101),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: selectedIndex == 0
                  ? Icons.home_filled
                  : Icons.home_outlined,
              index: 0,
              text: "Beranda"
            ),

            _buildNavItem(
              icon: selectedIndex == 1
                  ? Icons.monitor_weight
                  : Icons.monitor_weight_outlined,
              index: 1,
                text: "Analisis"
            ),
            _buildNavItem(
              icon: selectedIndex == 2 ? Icons.person : Icons.person_outline,
              index: 2,
                text: "Profil"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index,required String text}) {
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 26,
              color: selectedIndex == index
                  ? AppTheme.nutrinTrackGreen
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selectedIndex == index
                    ? AppTheme.nutrinTrackGreen
                    : Colors.grey.shade400
              ),
            ),
          ],
        ),
      ),
    );
  }
}
