import 'package:flutter/foundation.dart';

import '../../features/auth/customer_session_store.dart';
import '../../features/auth/signed_in_customer.dart';
import '../../features/booking/data/customer_booking_api.dart';
import '../../features/booking/models/appointment.dart';
import '../../features/bookings/data/sample_appointments.dart';
import '../../features/catalog/data/customer_catalogue_api.dart';
import '../../features/catalog/data/salon_catalog.dart';
import '../api/api_exception.dart';

class AppTab {
  AppTab._();

  static const home = 0;
  static const explore = 1;
  static const bookings = 2;
  static const profile = 3;
}

/// Session state for tabs, discovery filters, and locally confirmed visits.
class AppController extends ChangeNotifier {
  AppController({
    List<Appointment>? appointments,
    bool notificationsPreview = true,
    this.sessionStore,
  })  : appointments = List<Appointment>.of(
          appointments ?? SampleAppointments.seed(),
        ),
        _notificationsPreview = notificationsPreview;

  final CustomerSessionStore? sessionStore;

  final List<Appointment> appointments;

  int tabIndex = AppTab.home;
  String exploreQuery = '';
  String? categoryId;
  bool _notificationsPreview;
  SignedInCustomer? signedIn;
  SalonCatalog catalog = SalonCatalog.preview;
  bool catalogLoading = false;
  String? catalogError;
  CustomerCatalogueApi? catalogueApi;
  CustomerBookingApi? bookingApi;
  bool bookingsLoading = false;
  String? bookingsError;

  bool get notificationsPreview => _notificationsPreview;

  List<Appointment> get upcoming => appointments
      .where((appointment) => !appointment.isHistory())
      .toList()
    ..sort((a, b) => a.applicableDay.compareTo(b.applicableDay));

  List<Appointment> get past => appointments
      .where((appointment) => appointment.isHistory())
      .toList()
    ..sort((a, b) => b.applicableDay.compareTo(a.applicableDay));

  void setTab(int index) {
    if (tabIndex == index) return;
    tabIndex = index;
    notifyListeners();
    if (index == AppTab.bookings) {
      refreshBookings();
    }
  }

  void openExplore({String query = '', String? categoryId}) {
    exploreQuery = query;
    this.categoryId = categoryId;
    tabIndex = AppTab.explore;
    notifyListeners();
  }

  void setExploreQuery(String value) {
    if (exploreQuery == value) return;
    exploreQuery = value;
    notifyListeners();
  }

  void setCategory(String? id) {
    if (categoryId == id) return;
    categoryId = id;
    notifyListeners();
  }

  void clearDiscoveryFilters() {
    exploreQuery = '';
    categoryId = null;
    notifyListeners();
  }

  void showBookings() {
    tabIndex = AppTab.bookings;
    notifyListeners();
  }

  void showHome() {
    tabIndex = AppTab.home;
    notifyListeners();
  }

  void addAppointment(Appointment appointment) {
    appointments.insert(0, appointment);
    notifyListeners();
  }

  SalonCatalog get displayCatalog => signedIn == null ? SalonCatalog.preview : catalog;

  void signIn(SignedInCustomer customer) {
    signedIn = customer;
    appointments.clear();
    bookingsError = null;
    notifyListeners();
    sessionStore?.write(customer);
    refreshCatalogue();
    refreshBookings();
  }

  Future<void> restoreSession() async {
    final store = sessionStore;
    if (store == null || signedIn != null) return;
    final saved = await store.read();
    if (saved == null) return;
    if (!saved.expiresAt.isAfter(DateTime.now())) {
      await store.clear();
      return;
    }
    signIn(saved);
  }

  Future<void> refreshBookings() async {
    final token = signedIn?.accessToken;
    if (token == null || token.isEmpty) return;
    bookingsLoading = true;
    bookingsError = null;
    notifyListeners();
    try {
      final rows = await (bookingApi ?? CustomerBookingApi()).list(accessToken: token);
      appointments
        ..clear()
        ..addAll(rows.map((row) => row.toAppointment()));
      bookingsError = null;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && signedIn?.accessToken == token) {
        signOut();
        return;
      }
      bookingsError = error.message;
    } catch (_) {
      bookingsError = 'Cannot reach the salon server.';
    }
    bookingsLoading = false;
    notifyListeners();
  }

  Future<String?> requestCancellation(Appointment appointment) async {
    final token = signedIn?.accessToken;
    final id = int.tryParse(appointment.id);
    if (token == null || id == null) return 'Sign in again to request cancellation.';
    try {
      final saved = await (bookingApi ?? CustomerBookingApi()).requestCancellation(
        accessToken: token,
        appointmentId: id,
      );
      final index = appointments.indexWhere((item) => item.id == appointment.id);
      final mapped = saved.toAppointment();
      if (index >= 0) {
        appointments[index] = mapped;
      } else {
        appointments.insert(0, mapped);
      }
      notifyListeners();
      await refreshBookings();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Cannot reach the salon server.';
    }
  }

  Future<void> refreshCatalogue() async {
    final token = signedIn?.accessToken;
    if (token == null || token.isEmpty) {
      catalog = SalonCatalog.preview;
      catalogError = null;
      catalogLoading = false;
      notifyListeners();
      return;
    }
    catalogLoading = true;
    catalogError = null;
    notifyListeners();
    try {
      catalog = await (catalogueApi ?? CustomerCatalogueApi()).load(token);
      catalogError = null;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && signedIn?.accessToken == token) {
        signOut();
        return;
      }
      catalog = SalonCatalog.emptyLive;
      catalogError = error.message;
    } catch (_) {
      catalog = SalonCatalog.emptyLive;
      catalogError = 'Cannot reach the salon server.';
    }
    catalogLoading = false;
    notifyListeners();
  }

  void signOut() {
    sessionStore?.clear();
    signedIn = null;
    catalog = SalonCatalog.preview;
    catalogLoading = false;
    catalogError = null;
    bookingsLoading = false;
    bookingsError = null;
    appointments
      ..clear()
      ..addAll(SampleAppointments.seed());
    notifyListeners();
  }

  void setNotificationsPreview(bool value) {
    if (_notificationsPreview == value) return;
    _notificationsPreview = value;
    notifyListeners();
  }
}
