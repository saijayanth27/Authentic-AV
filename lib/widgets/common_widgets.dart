import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool outline;
  
  const AvBadge({
    super.key, 
    required this.text, 
    required this.color,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: outline ? color : color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AvCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isSelected;
  final VoidCallback? onTap;

  const AvCard({
    super.key, 
    required this.child, 
    this.padding,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.highlightGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentWhite : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class AvStatusIndicator extends StatelessWidget {
  final bool isOnline;
  const AvStatusIndicator({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.statusOnline : AppTheme.statusOffline,
        shape: BoxShape.circle,
      ),
    );
  }
}
