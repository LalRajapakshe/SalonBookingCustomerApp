import 'package:flutter/material.dart';

import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/booking_summary.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../catalog/data/mock_catalog.dart';
import '../models/demo_booking.dart';
import '../widgets/demo_notice.dart';

class DemoBookingSuccessScreen extends StatelessWidget {
  const DemoBookingSuccessScreen({required this.booking, super.key});

  final DemoBooking booking;

  @override
  Widget build(BuildContext context) {
    final service = MockCatalog.serviceById(booking.serviceId);

    return Scaffold(
      body: SafeArea(
        child: service == null
            ? const EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Demo booking unavailable',
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
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Align(
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
                  ),
                  const SizedBox(height: 18),
                  Text('Demo booking saved', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    'Saved in this preview only.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  const DemoNotice(
                    message:
                        'A salon has not confirmed this time. It will not appear in My bookings.',
                  ),
                  const SizedBox(height: 16),
                  BookingSummary(
                    service: service,
                    stylistId: booking.stylistId,
                    start: booking.start,
                  ),
                  const SizedBox(height: 22),
                  AppSecondaryButton(
                    key: const Key('calendar-back'),
                    label: 'Back to calendar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 10),
                  AppPrimaryButton(
                    key: const Key('calendar-finish'),
                    label: 'Finish',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
