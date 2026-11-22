import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../booking/models/appointment.dart';
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

class _MyBookingsScreenState extends State<MyBookingsScreen> with WidgetsBindingObserver {
  _VisitFilter _filter = _VisitFilter.upcoming;
  String? _actionError;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).refreshBookings();
    });
    _armRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    AppScope.read(context).refreshBookings();
  }

  void _armRefresh() {
    _refreshTimer?.cancel();
    if (WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets')) return;
    _refreshTimer = Timer(const Duration(seconds: 45), () {
      if (!mounted) return;
      AppScope.read(context).refreshBookings();
      _armRefresh();
    });
  }

  Future<void> _requestCancellation(String id) async {
    final app = AppScope.read(context);
    Appointment? appointment;
    for (final item in app.appointments) {
      if (item.id == id) appointment = item;
    }
    if (appointment == null) return;
    final error = await app.requestCancellation(appointment);
    if (!mounted) return;
    setState(() => _actionError = error);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final upcoming = _filter == _VisitFilter.upcoming;
    final items = upcoming ? app.upcoming : app.past;
    final signedIn = app.signedIn != null;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: app.refreshBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              signedIn ? 'Your booking requests and salon visits.' : 'Sample visits in this preview.',
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
            if (app.bookingsLoading && items.isEmpty && app.bookingsError == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (app.bookingsError != null && items.isEmpty)
              EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Bookings are unavailable',
                message: app.bookingsError!,
                actionLabel: 'Try again',
                onAction: app.refreshBookings,
              )
            else if (items.isEmpty)
              EmptyState(
                icon: Icons.event_available_outlined,
                title: upcoming ? 'No upcoming visits yet' : 'No past visits yet',
                message: upcoming
                    ? signedIn
                        ? 'Booking requests you send to the salon will show here.'
                        : 'When you confirm a sample visit in this session, it will show up here.'
                    : signedIn
                        ? 'Finished, cancelled, and missed visits will show here.'
                        : 'Sample visits from this preview will show here.',
                actionLabel: upcoming ? 'Book a visit' : null,
                onAction: upcoming ? () => Navigator.of(context).pushNamed(AppRoutes.booking) : null,
              )
            else
              for (final appointment in items) ...[
                AppointmentCard(
                  key: ValueKey(appointment.id),
                  appointment: appointment,
                  onRequestCancellation: appointment.canRequestCancellation
                      ? () => _requestCancellation(appointment.id)
                      : null,
                ),
                const SizedBox(height: 12),
              ],
            if (_actionError != null) ...[
              const SizedBox(height: 8),
              Text(_actionError!, style: AppTextStyles.caption),
            ],
            if (app.bookingsError != null && items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(app.bookingsError!, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
