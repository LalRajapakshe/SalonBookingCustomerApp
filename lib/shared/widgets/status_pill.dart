import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/booking/models/appointment.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == AppointmentStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFEDE9FE) : AppColors.successSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: completed ? AppColors.purple : AppColors.success,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
