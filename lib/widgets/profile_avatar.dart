import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.size = 60,
  });

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : 'U';
  }

  Color get backgroundColor {
    final hash = initials.hashCode;
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: [AppTheme.mediumShadow],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
