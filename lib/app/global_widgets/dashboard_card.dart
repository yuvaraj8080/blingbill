import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Set colors based on dark mode
    final Color cardColor = isDarkMode 
        ? AppConstants.darkCardColor 
        : AppConstants.lightCardColor;
    
    final Color titleColor = isDarkMode 
        ? AppConstants.textLight.withOpacity(0.8) 
        : AppConstants.textDark.withOpacity(0.8);
    
    final Color subtitleColor = isDarkMode 
        ? AppConstants.textLight.withOpacity(0.6) 
        : AppConstants.textMedium;
    
    final Color valueColor = value.startsWith('₹')
        ? AppConstants.successColor
        : (isDarkMode ? AppConstants.textLight : AppConstants.textDark);

    return Card(
      elevation: AppConstants.cardElevation,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        side: BorderSide(
          color: isDarkMode 
              ? Colors.grey.shade800 
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: AppConstants.spacing_xxs),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing_xs),
              Text(
                value, 
                style: GoogleFonts.inter(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600, 
                  color: valueColor
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppConstants.spacing_xxs),
                Text(
                  subtitle!, 
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}