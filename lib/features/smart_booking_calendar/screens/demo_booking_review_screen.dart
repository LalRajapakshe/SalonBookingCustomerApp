import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/booking_summary.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../catalog/data/mock_catalog.dart';
import '../state/calendar_scope.dart';
import '../widgets/demo_notice.dart';

class DemoBookingReviewScreen extends StatefulWidget {
  const DemoBookingReviewScreen({super.key});

  @override
  State<DemoBookingReviewScreen> createState() => _DemoBookingReviewScreenState();
}

class _DemoBookingReviewScreenState extends State<DemoBookingReviewScreen> {
  bool _busy = false;

  void _confirm() {
    if (_busy) return;
    setState(() => _busy = true);
    final booking = CalendarScope.read(context).confirm();
    if (!mounted) return;
    if (booking == null) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That demo time is no longer available.')),
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.smartCalendarConfirmed,
      arguments: booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = CalendarScope.of(context).draft();
    final service = draft == null ? null : MockCatalog.serviceById(draft.serviceId);

    return Scaffold(
      appBar: AppBar(title: const Text('Review demo booking')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppPrimaryButton(
          key: const Key('calendar-confirm'),
          label: _busy ? 'Saving demo booking' : 'Confirm demo booking',
          onPressed: draft == null || service == null || _busy ? null : _confirm,
        ),
      ),
      body: draft == null || service == null
          ? const EmptyState(
              icon: Icons.event_busy_rounded,
              title: 'Nothing to review',
              message: 'Choose a service, stylist, and demo time first.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                8,
                AppDimensions.screenPadding,
                24,
              ),
              children: [
                const DemoNotice(
                  message:
                      'This is a local demo booking. It does not reserve a salon appointment.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Check the sample details before you save them on this device.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 14),
                BookingSummary(
                  service: service,
                  stylistId: draft.stylistId,
                  start: draft.start,
                ),
              ],
            ),
    );
  }
}
