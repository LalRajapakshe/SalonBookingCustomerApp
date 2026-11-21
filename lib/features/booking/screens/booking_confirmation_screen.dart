import 'package:flutter/material.dart';

import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/booking_summary.dart';
import '../../../shared/widgets/empty_state.dart';
import '../models/appointment.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final service = AppScope.of(context).displayCatalog.serviceById(appointment.serviceId);

    return Scaffold(
      body: SafeArea(
        child: service == null
            ? const EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Visit unavailable',
                message: 'That service is not in this preview.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  28,
                  AppDimensions.screenPadding,
                  24,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        gradient: AppDecorations.brand,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text("You're booked", style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    appointment.storedOnServer
                        ? 'Sent to the salon. They will set the time.'
                        : 'Saved in this session.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 22),
                  BookingSummary(
                    service: service,
                    stylistId: appointment.stylistId,
                    start: appointment.start,
                  ),
                  const SizedBox(height: 22),
                  AppPrimaryButton(
                    key: const Key('view-bookings'),
                    label: 'View my bookings',
                    onPressed: () {
                      AppScope.read(context).showBookings();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: 10),
                  AppSecondaryButton(
                    label: 'Back to home',
                    onPressed: () {
                      AppScope.read(context).showHome();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
