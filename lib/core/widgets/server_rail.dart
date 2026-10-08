import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../theme/app_colors.dart';
import '../constants/asset_paths.dart';

class ServerRail extends StatelessWidget {
  final int selectedIndex; // 0: Padma/Home, 1: Mirpur, 2: Uttara, 3: Mohammadpur
  final void Function(int index) onSelectIndex;
  final VoidCallback? onProfileTap;
  final UserModel? currentUser;

  const ServerRail({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    this.onProfileTap,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final railBg = isDark ? AppColors.darkSurfaceRail : const Color(0xFF0F1B24);

    return Container(
      width: 72,
      color: railBg,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Padma Server Icon with Left Pill Indicator
            _ServerRailIcon(
              isSelected: selectedIndex == 0,
              badgeContent: 'AUST',
              imageAsset: AssetPaths.logo,
              onTap: () => onSelectIndex(0),
              tooltip: 'Padma - AUST Transit Hub',
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Divider(color: AppColors.darkBorder, thickness: 1.5),
            ),

            // Route 1 (Mirpur)
            _ServerRailIcon(
              isSelected: selectedIndex == 1,
              iconText: 'M',
              icon: Icons.directions_bus_rounded,
              color: AppColors.darkPrimary,
              onTap: () => onSelectIndex(1),
              tooltip: 'Bus 1 • Mirpur Route',
            ),
            const SizedBox(height: 10),

            // Route 2 (Uttara)
            _ServerRailIcon(
              isSelected: selectedIndex == 2,
              iconText: 'U',
              icon: Icons.directions_bus_rounded,
              color: AppColors.darkSecondary,
              onTap: () => onSelectIndex(2),
              tooltip: 'Bus 2 • Uttara Route',
            ),
            const SizedBox(height: 10),

            // Route 3 (Mohammadpur)
            _ServerRailIcon(
              isSelected: selectedIndex == 3,
              iconText: 'MP',
              icon: Icons.directions_bus_rounded,
              color: const Color(0xFFFF7043),
              onTap: () => onSelectIndex(3),
              tooltip: 'Bus 3 • Mohammadpur Route',
            ),

            const Spacer(),

            // Profile Avatar with presence green dot
            GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkSecondary.withValues(alpha: 0.8),
                        width: 1.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentUser?.name.isNotEmpty == true
                          ? currentUser!.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSecondary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: railBg, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ServerRailIcon extends StatelessWidget {
  final bool isSelected;
  final String? badgeContent;
  final String? iconText;
  final IconData? icon;
  final Color? color;
  final String? imageAsset;
  final VoidCallback onTap;
  final String tooltip;

  const _ServerRailIcon({
    required this.isSelected,
    this.badgeContent,
    this.iconText,
    this.icon,
    this.color,
    this.imageAsset,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left selection pill indicator
              Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: isSelected ? 36 : 0,
                  decoration: const BoxDecoration(
                    color: AppColors.darkPrimary,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),

              // Icon Container morphing between square (radius 14) and circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (color ?? AppColors.darkPrimary).withValues(alpha: 0.25)
                      : AppColors.darkSurface1,
                  borderRadius: BorderRadius.circular(isSelected ? 14 : 23),
                  border: Border.all(
                    color: isSelected
                        ? (color ?? AppColors.darkPrimary)
                        : AppColors.darkBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: imageAsset != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(isSelected ? 12 : 21),
                          child: Image.asset(imageAsset!, width: 34, height: 34),
                        )
                      : (icon != null
                          ? Icon(icon, size: 22, color: color ?? AppColors.darkTextPrimary)
                          : Text(
                              badgeContent ?? iconText ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color ?? AppColors.darkTextPrimary,
                              ),
                            )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
