import 'package:flutter/material.dart';

import '../../../core/format/display_format.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../catalog/data/mock_catalog.dart';
import '../../catalog/models/salon_service.dart';
import '../data/demo_availability.dart';
import '../state/calendar_scope.dart';
import '../widgets/demo_notice.dart';
import '../widgets/month_calendar.dart';

class SmartCalendarScreen extends StatefulWidget {
  const SmartCalendarScreen({this.initialServiceId, super.key});

  final String? initialServiceId;

  @override
  State<SmartCalendarScreen> createState() => _SmartCalendarScreenState();
}

class _SmartCalendarScreenState extends State<SmartCalendarScreen> {
  @override
  void initState() {
    super.initState();
    final initial = widget.initialServiceId;
    if (initial == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CalendarScope.read(context).selectService(initial);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendar = CalendarScope.of(context);
    final service = calendar.selectedService;
    final slots = calendar.slotsFor(calendar.selectedDate);
    final hadTemplate = DemoAvailability.hasTemplate(calendar.selectedDate);
    final stylists = service == null ? const [] : MockCatalog.stylistsForService(service);

    return Scaffold(
      appBar: AppBar(title: const Text('Demo calendar')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppPrimaryButton(
          key: const Key('calendar-review'),
          label: 'Review demo booking',
          onPressed: calendar.canReview
              ? () => Navigator.of(context).pushNamed(AppRoutes.smartCalendarReview)
              : null,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          4,
          AppDimensions.screenPadding,
          20,
        ),
        children: [
          const DemoNotice(key: Key('calendar-demo-notice')),
          const SizedBox(height: 8),
          MonthCalendar(
            visibleMonth: calendar.visibleMonth,
            selectedDate: calendar.selectedDate,
            today: DateTime(calendar.now.year, calendar.now.month, calendar.now.day),
            onPrevious: calendar.showPreviousMonth,
            onNext: calendar.showNextMonth,
            onSelect: calendar.selectDate,
            hasSelectableSlots: calendar.dayHasSelectableSlots,
          ),
          const SizedBox(height: 8),
          Text(
            DisplayFormat.date(calendar.selectedDate),
            key: const Key('calendar-selected-date'),
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Sample openings for this date. Nothing here is reserved yet.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          if (slots.isEmpty)
            EmptyState(
              icon: Icons.event_busy_rounded,
              title: hadTemplate ? 'No demo times left' : 'No demo openings',
              message: hadTemplate
                  ? 'Sample times for this date are in the past or already used in this preview.'
                  : 'This date has no demo openings. Demo data is not live availability.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in slots)
                  _ChoiceChip(
                    key: ValueKey('calendar-slot-${slot.id}'),
                    label: DisplayFormat.timeOf(slot.start),
                    selected: calendar.selectedSlotId == slot.id,
                    onTap: () => calendar.selectSlot(slot.id),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          Text('Catalogue service', style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockCatalog.services.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = MockCatalog.services[index];
                return _ChoiceChip(
                  key: ValueKey('calendar-service-${item.id}'),
                  label: item.name,
                  selected: calendar.serviceId == item.id,
                  onTap: () => calendar.selectService(item.id),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ServiceSummary(service: service),
          const SizedBox(height: 16),
          Text('Stylist', style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          if (service == null)
            Text(
              'Select a catalogue service to see stylists.',
              style: AppTextStyles.caption,
            )
          else
            SizedBox(
              key: const Key('calendar-stylist-list'),
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stylists.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _ChoiceChip(
                      key: const ValueKey('calendar-stylist-any'),
                      label: MockCatalog.anyStylistLabel,
                      selected: calendar.stylistId == MockCatalog.anyStylistId,
                      onTap: () => calendar.selectStylist(MockCatalog.anyStylistId),
                    );
                  }
                  final stylist = stylists[index - 1];
                  return _ChoiceChip(
                    key: ValueKey('calendar-stylist-${stylist.id}'),
                    label: stylist.name,
                    selected: calendar.stylistId == stylist.id,
                    onTap: () => calendar.selectStylist(stylist.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({required this.service});

  final SalonService? service;

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return Text(
        'Choose a service from the catalogue to continue.',
        style: AppTextStyles.caption,
      );
    }
    return Container(
      key: const Key('calendar-service-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service!.name, style: AppTextStyles.cardTitle),
          const SizedBox(height: 4),
          Text(
            DisplayFormat.duration(service!.durationMinutes),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 4),
          Text(
            'Sample price ${DisplayFormat.money(service!.price)}',
            style: AppTextStyles.price,
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onPrimary : AppColors.heading;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
