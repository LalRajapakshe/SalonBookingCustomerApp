import 'package:flutter/foundation.dart';

import '../../catalog/data/mock_catalog.dart';
import '../../catalog/models/salon_service.dart';
import '../data/demo_availability.dart';
import '../models/demo_booking.dart';
import '../models/demo_slot.dart';

/// Isolated state for the demo calendar.
///
/// Confirmed visits stay in this controller. They are not added to the
/// existing appointments list.
class CalendarController extends ChangeNotifier {
  CalendarController({DateTime Function()? now}) : _now = now ?? DateTime.now {
    final today = _today;
    visibleMonth = DateTime(today.year, today.month);
    selectedDate = today;
  }

  final DateTime Function() _now;
  final List<DemoBooking> bookings = [];
  final Set<String> _bookedSlotIds = {};

  late DateTime visibleMonth;
  late DateTime selectedDate;
  String? serviceId;
  String? stylistId;
  String? selectedSlotId;
  bool _confirmInFlight = false;

  DateTime get now => _now();

  DateTime get _today {
    final clock = now;
    return DateTime(clock.year, clock.month, clock.day);
  }

  SalonService? get selectedService {
    final id = serviceId;
    if (id == null) return null;
    return MockCatalog.serviceById(id);
  }

  bool get canReview => draft() != null;

  void showPreviousMonth() {
    visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    _keepSelectionInView();
    notifyListeners();
  }

  void showNextMonth() {
    visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    _keepSelectionInView();
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day == selectedDate) return;
    selectedDate = day;
    visibleMonth = DateTime(day.year, day.month);
    selectedSlotId = null;
    notifyListeners();
  }

  void selectService(String id) {
    if (MockCatalog.serviceById(id) == null) return;
    if (serviceId == id) return;
    serviceId = id;
    stylistId = null;
    selectedSlotId = null;
    notifyListeners();
  }

  void selectStylist(String id) {
    final service = selectedService;
    if (service == null) return;
    final allowed = id == MockCatalog.anyStylistId || service.stylistIds.contains(id);
    if (!allowed) return;
    if (stylistId == id) return;
    stylistId = id;
    notifyListeners();
  }

  void selectSlot(String id) {
    final match = slotsFor(selectedDate).where((slot) => slot.id == id);
    if (match.isEmpty) return;
    selectedSlotId = id;
    notifyListeners();
  }

  List<DemoSlot> slotsFor(DateTime date) {
    return DemoAvailability.slotsFor(
      date: date,
      now: now,
      bookedSlotIds: _bookedSlotIds,
    );
  }

  bool dayHasSelectableSlots(DateTime date) => slotsFor(date).isNotEmpty;

  DemoBookingDraft? draft() {
    final service = selectedService;
    final stylist = stylistId;
    final slotId = selectedSlotId;
    if (service == null || stylist == null || slotId == null) return null;
    if (_bookedSlotIds.contains(slotId)) return null;
    final slot = slotsFor(selectedDate).where((item) => item.id == slotId).firstOrNull;
    if (slot == null || !slot.start.isAfter(now)) return null;
    return DemoBookingDraft(
      slotId: slot.id,
      serviceId: service.id,
      stylistId: stylist,
      start: slot.start,
      durationMinutes: service.durationMinutes,
      price: service.price,
    );
  }

  /// Confirms the current draft once. A second call does not create another booking.
  DemoBooking? confirm() {
    if (_confirmInFlight) return null;
    final current = draft();
    if (current == null) return null;
    _confirmInFlight = true;
    try {
      _bookedSlotIds.add(current.slotId);
      final booking = DemoBooking(
        id: 'demo-${current.slotId}',
        slotId: current.slotId,
        serviceId: current.serviceId,
        stylistId: current.stylistId,
        start: current.start,
        durationMinutes: current.durationMinutes,
        price: current.price,
      );
      bookings.insert(0, booking);
      selectedSlotId = null;
      notifyListeners();
      return booking;
    } finally {
      _confirmInFlight = false;
    }
  }

  void _keepSelectionInView() {
    final inMonth = selectedDate.year == visibleMonth.year &&
        selectedDate.month == visibleMonth.month;
    if (inMonth) return;
    final today = _today;
    if (today.year == visibleMonth.year && today.month == visibleMonth.month) {
      selectedDate = today;
    } else {
      selectedDate = DateTime(visibleMonth.year, visibleMonth.month, 1);
    }
    selectedSlotId = null;
  }
}
