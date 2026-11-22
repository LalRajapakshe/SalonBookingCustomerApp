import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/category_visuals.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/booking_summary.dart';
import '../../../shared/widgets/date_selector.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/initials_avatar.dart';
import '../../../core/theme/catalog_images.dart';
import '../../../shared/widgets/catalog_image.dart';
import '../../../shared/widgets/price_duration_label.dart';
import '../../../shared/widgets/selectable_card.dart';
import '../../../shared/widgets/time_slot_selector.dart';
import '../../catalog/data/customer_catalogue_api.dart';
import '../../catalog/data/salon_catalog.dart';
import '../../catalog/models/salon_service.dart';
import '../../catalog/models/stylist.dart';
import '../../../core/time/salon_time.dart';
import '../data/customer_booking_api.dart';
import '../data/mock_availability.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({this.initialServiceId, this.bookingApi, super.key});

  final String? initialServiceId;
  final CustomerBookingApi? bookingApi;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  static const _titles = [
    'Choose a service',
    'Choose a stylist',
    'Choose a date',
    'Choose a time',
    'Review',
  ];

  int _step = 0;
  bool _pickedInitial = false;
  String? _serviceId;
  String? _stylistId;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  String? _saveError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pickedInitial) return;
    _pickedInitial = true;
    final initial = widget.initialServiceId;
    final known = initial != null && _catalog.serviceById(initial) != null;
    _serviceId = known ? initial : null;
    _step = known ? 1 : 0;
  }

  SalonCatalog get _catalog => AppScope.of(context).displayCatalog;

  SalonService? get _service =>
      _serviceId == null ? null : _catalog.serviceById(_serviceId!);

  bool get _canContinue => switch (_step) {
        0 => _serviceId != null,
        1 => _stylistId != null,
        2 => _date != null,
        3 => _time != null,
        _ => _service != null && _stylistId != null && _date != null && _time != null,
      };

  String? get _blockedReason => switch (_step) {
        0 when _serviceId == null => 'Select a service to continue.',
        1 when _stylistId == null => 'Select a stylist to continue.',
        2 when _date == null => 'Select a date to continue.',
        3 when _time == null => 'Select a time to continue.',
        _ => null,
      };

  void _selectService(String id) {
    setState(() {
      if (_serviceId != id) {
        _serviceId = id;
        if (_stylistId != null && _stylistId != SalonCatalog.anyStylistId) {
          final service = _catalog.serviceById(id);
          if (service == null || !service.stylistIds.contains(_stylistId)) {
            _stylistId = null;
          }
        }
        _time = null;
      }
    });
  }

  void _selectStylist(String id) {
    setState(() {
      if (_stylistId != id) _time = null;
      _stylistId = id;
    });
  }

  void _selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    setState(() {
      _date = day;
      _time = null;
    });
  }

  void _next() {
    if (!_canContinue || _step >= 4) return;
    setState(() => _step += 1);
  }

  Future<void> _confirm() async {
    final service = _service;
    if (service == null || _stylistId == null || _date == null || _time == null || _saving) {
      return;
    }
    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final signedIn = AppScope.read(context).signedIn;
    final serviceId = service.numericId;
    final branchId = service.numericBranchId;
    if (signedIn == null || !_catalog.isLive || serviceId == null || branchId == null) {
      _openConfirmation(
        Appointment(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          serviceId: service.id,
          stylistId: _stylistId!,
          start: start,
          status: AppointmentStatus.confirmed,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final api = widget.bookingApi ?? CustomerBookingApi();
      final preferredEmployeeId =
          _stylistId == SalonCatalog.anyStylistId ? null : int.tryParse(_stylistId ?? '');
      final appointmentId = await api.create(
        accessToken: signedIn.accessToken,
        serviceId: serviceId,
        branchId: branchId,
        preferredEmployeeId: preferredEmployeeId,
        start: start,
        notes: preferredEmployeeId == null ? 'No stylist preference' : null,
      );
      if (!mounted) return;
      final app = AppScope.read(context);
      await app.refreshBookings();
      if (!mounted) return;
      if (!app.appointments.any((item) => item.id == '$appointmentId')) {
        app.addAppointment(
          Appointment(
            id: '$appointmentId',
            serviceId: service.id,
            stylistId: _stylistId!,
            start: start,
            status: AppointmentStatus.pending,
            storedOnServer: true,
            serviceName: service.name,
            branchName: service.salonId,
            requestedStart: start,
          ),
        );
      }
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.confirmation,
        arguments: app.appointments.firstWhere((item) => item.id == '$appointmentId'),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = error.message;
      });
    }
  }

  void _openConfirmation(Appointment appointment) {
    AppScope.read(context).addAppointment(appointment);
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.confirmation,
      arguments: appointment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _step -= 1);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_titles[_step])),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_saveError != null) ...[
                Text(_saveError!, style: AppTextStyles.caption),
                const SizedBox(height: 8),
              ] else if (_blockedReason != null) ...[
                Text(_blockedReason!, style: AppTextStyles.caption),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Back',
                        onPressed: () => setState(() => _step -= 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppPrimaryButton(
                      key: const Key('booking-next'),
                      label: _saving
                          ? 'Saving…'
                          : _step == 4
                              ? 'Confirm appointment'
                              : 'Continue',
                      onPressed: !_canContinue || _saving
                          ? null
                          : _step == 4
                              ? _confirm
                              : _next,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _StepBar(step: _step),
            ),
            if (_service != null && _step > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  _service!.name,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  switch (_step) {
                    0 => _ServiceStep(
                        selectedId: _serviceId,
                        onSelected: _selectService,
                      ),
                    1 => _StylistStep(
                        service: _service,
                        selectedId: _stylistId,
                        onSelected: _selectStylist,
                      ),
                    2 => _DateStep(
                        live: _catalog.isLive &&
                            AppScope.of(context).signedIn != null &&
                            _service?.numericId != null &&
                            _service?.numericBranchId != null,
                        accessToken: AppScope.of(context).signedIn?.accessToken,
                        service: _service,
                        stylistId: _stylistId,
                        selected: _date,
                        onSelected: _selectDate,
                      ),
                    3 => _TimeStep(
                        date: _date,
                        stylistId: _stylistId,
                        service: _service,
                        live: _catalog.isLive,
                        accessToken: AppScope.of(context).signedIn?.accessToken,
                        selected: _time,
                        onSelected: (time) => setState(() => _time = time),
                      ),
                    _ => _ReviewStep(
                        service: _service,
                        stylistId: _stylistId,
                        date: _date,
                        time: _time,
                        live: _catalog.isLive && AppScope.of(context).signedIn != null,
                      ),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < 5; index++)
          Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
              decoration: BoxDecoration(
                color: index <= step ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServiceStep extends StatelessWidget {
  const _ServiceStep({required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final service in AppScope.of(context).displayCatalog.services) ...[
          SelectableCard(
            key: ValueKey('pick-service-${service.id}'),
            selected: selectedId == service.id,
            onTap: () => onSelected(service.id),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CatalogImage(
                    assetPath: CatalogImages.forCategory(service.categoryId),
                    fallbackCategoryId: service.categoryId,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppScope.of(context).displayCatalog.categoryName(service.categoryId),
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.name,
                        style: AppTextStyles.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      PriceDurationLabel(
                        price: service.price,
                        durationMinutes: service.durationMinutes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StylistStep extends StatelessWidget {
  const _StylistStep({
    required this.service,
    required this.selectedId,
    required this.onSelected,
  });

  final SalonService? service;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.of(context).displayCatalog;
    final stylists = service == null ? const <Stylist>[] : catalog.stylistsForService(service!);
    return Column(
      children: [
        SelectableCard(
          key: const ValueKey('pick-stylist-any'),
          selected: selectedId == SalonCatalog.anyStylistId,
          onTap: () => onSelected(SalonCatalog.anyStylistId),
          child: Row(
            children: [
              const InitialsAvatar(
                initials: 'Any',
                colors: [AppColors.coral, AppColors.purple],
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(SalonCatalog.anyStylistLabel, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Match whoever is free for this service.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final stylist in stylists) ...[
          SelectableCard(
            key: ValueKey('pick-stylist-${stylist.id}'),
            selected: selectedId == stylist.id,
            onTap: () => onSelected(stylist.id),
            child: Row(
              children: [
                InitialsAvatar(
                  initials: stylist.initials,
                  colors: CategoryVisuals.gradient(stylist.categoryId),
                  size: 52,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stylist.name, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(stylist.specialty, style: AppTextStyles.caption),
                      if (stylist.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(stylist.description, style: AppTextStyles.caption),
                      ],
                      if (stylist.qualifications.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          stylist.qualifications
                              .map((item) => item.isVerified ? '${item.name} (verified)' : item.name)
                              .join(', '),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                if (stylist.rating >= 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                      Text(
                        stylist.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TimeStep extends StatefulWidget {
  const _TimeStep({
    required this.date,
    required this.stylistId,
    required this.service,
    required this.live,
    required this.accessToken,
    required this.selected,
    required this.onSelected,
  });

  final DateTime? date;
  final String? stylistId;
  final SalonService? service;
  final bool live;
  final String? accessToken;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onSelected;

  @override
  State<_TimeStep> createState() => _TimeStepState();
}

class _TimeStepState extends State<_TimeStep> {
  List<TimeSlot> _slots = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _TimeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.stylistId != widget.stylistId ||
        oldWidget.service?.id != widget.service?.id ||
        oldWidget.live != widget.live) {
      _load();
    }
  }

  Future<void> _load() async {
    final date = widget.date;
    final stylistId = widget.stylistId;
    final service = widget.service;
    if (date == null || stylistId == null) return;
    if (!widget.live || widget.accessToken == null || service?.numericId == null || service?.numericBranchId == null) {
      setState(() {
        _slots = MockAvailability.slotsFor(date: date, stylistId: stylistId);
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await (AppScope.read(context).catalogueApi ?? CustomerCatalogueApi()).availability(
        accessToken: widget.accessToken!,
        branchId: service!.numericBranchId!,
        serviceId: service.numericId!,
        date: date,
        employeeId: stylistId == SalonCatalog.anyStylistId ? null : int.tryParse(stylistId),
      );
      if (!mounted) return;
      setState(() {
        _slots = [
          for (final row in rows)
            if (!SalonTime.isPastSlot(date, row.start.hour, row.start.minute))
              TimeSlot(
                time: TimeOfDay(hour: row.start.hour, minute: row.start.minute),
                available: row.available,
              ),
        ];
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
        _slots = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.date == null || widget.stylistId == null) {
      return const EmptyState(
        icon: Icons.schedule_rounded,
        title: 'Choose a date first',
        message: 'Times appear after you pick a day.',
      );
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Times are unavailable',
        message: _error!,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.live ? 'Times' : 'Sample times', style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Text(
          widget.live
              ? 'Grey times are unavailable. Choosing a time sends a request. It does not reserve the time.'
              : 'These openings are sample preview times, not the salon calendar.',
          style: AppTextStyles.caption,
        ),
        if (widget.service != null) ...[
          const SizedBox(height: 6),
          Text('${widget.service!.durationMinutes} minutes', style: AppTextStyles.caption),
        ],
        const SizedBox(height: 16),
        if (_slots.isEmpty)
          const EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No times this day',
            message: 'Try another date.',
          )
        else
          TimeSlotSelector(
            slots: _slots,
            selected: widget.selected,
            onSelected: widget.onSelected,
          ),
      ],
    );
  }
}

class _DateStep extends StatefulWidget {
  const _DateStep({
    required this.live,
    required this.accessToken,
    required this.service,
    required this.stylistId,
    required this.selected,
    required this.onSelected,
  });

  final bool live;
  final String? accessToken;
  final SalonService? service;
  final String? stylistId;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  State<_DateStep> createState() => _DateStepState();
}

class _DateStepState extends State<_DateStep> {
  List<DateTime> _dates = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _DateStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live ||
        oldWidget.stylistId != widget.stylistId ||
        oldWidget.service?.id != widget.service?.id) {
      _load();
    }
  }

  Future<void> _load() async {
    final service = widget.service;
    if (!widget.live || widget.accessToken == null || service?.numericId == null || service?.numericBranchId == null) {
      setState(() {
        _dates = MockAvailability.upcomingDates();
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _dates = const [];
    });
    final start = SalonTime.today();
    final employeeId = widget.stylistId == null || widget.stylistId == SalonCatalog.anyStylistId
        ? null
        : int.tryParse(widget.stylistId!);
    try {
      final api = AppScope.read(context).catalogueApi ?? CustomerCatalogueApi();
      final checks = await Future.wait([
        for (var index = 0; index < 14; index++)
          api.availability(
            accessToken: widget.accessToken!,
            branchId: service!.numericBranchId!,
            serviceId: service.numericId!,
            date: start.add(Duration(days: index)),
            employeeId: employeeId,
          ),
      ]);
      if (!mounted) return;
      final open = <DateTime>[];
      for (var index = 0; index < checks.length; index++) {
        if (checks[index].any((slot) => slot.available)) {
          open.add(start.add(Duration(days: index)));
        }
      }
      setState(() {
        _dates = open;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
        _dates = const [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Cannot reach the salon server.';
        _dates = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Dates are unavailable',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _load,
      );
    }
    if (widget.live && _dates.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No open days',
        message: 'The salon has no available time in the next two weeks for this service.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.live ? 'Open days' : 'Sample dates', style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Text(
          widget.live
              ? 'These days come from the salon calendar. A time you choose is a request, not a reserved slot.'
              : 'These dates are sample preview data, not the salon calendar.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 16),
        DateSelector(
          dates: _dates,
          selected: widget.selected,
          onSelected: widget.onSelected,
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.service,
    required this.stylistId,
    required this.date,
    required this.time,
    required this.live,
  });

  final SalonService? service;
  final String? stylistId;
  final DateTime? date;
  final TimeOfDay? time;
  final bool live;

  @override
  Widget build(BuildContext context) {
    if (service == null || stylistId == null || date == null || time == null) {
      return const EmptyState(
        icon: Icons.fact_check_outlined,
        title: 'Details missing',
        message: 'Go back and finish each step.',
      );
    }
    final start = DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          live
              ? 'Confirming sends a booking request. The salon confirms the time afterwards.'
              : 'Confirming saves this sample visit in the current session.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 14),
        BookingSummary(
          service: service!,
          stylistId: stylistId!,
          start: start,
        ),
      ],
    );
  }
}
