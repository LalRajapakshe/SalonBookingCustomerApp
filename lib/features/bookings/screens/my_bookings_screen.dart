import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/appointment_card.dart';

enum _VisitFilter { upcoming, past }

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  _VisitFilter _filter = _VisitFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final upcoming = _filter == _VisitFilter.upcoming;
    final items = upcoming ? app.upcoming : app.past;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          8,
          AppDimensions.screenPadding,
          28,
        ),
        children: [
          Text('My bookings', style: AppTextStyles.display),
          const SizedBox(height: 6),
          Text(
            'Upcoming and earlier visits.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          SegmentedButton<_VisitFilter>(
            key: const Key('booking-filter'),
            showSelectedIcon: false,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.primary;
                return Colors.white;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return AppColors.heading;
              }),
              side: const WidgetStatePropertyAll(
                BorderSide(color: AppColors.border),
              ),
            ),
            segments: const [
              ButtonSegment(
                value: _VisitFilter.upcoming,
                label: Text('Upcoming'),
              ),
              ButtonSegment(
                value: _VisitFilter.past,
                label: Text('Past'),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) {
              setState(() => _filter = selection.first);
            },
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            EmptyState(
              icon: Icons.event_available_outlined,
              title: upcoming ? 'No upcoming visits yet' : 'No past visits yet',
              message: upcoming
                  ? 'When you confirm a visit in this session, it will show up here.'
                  : 'Completed visits from this preview will show here.',
              actionLabel: upcoming ? 'Book a visit' : null,
              onAction: upcoming
                  ? () => Navigator.of(context).pushNamed(AppRoutes.booking)
                  : null,
            )
          else
            for (final appointment in items) ...[
              AppointmentCard(
                key: ValueKey(appointment.id),
                appointment: appointment,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
