import 'package:flutter/foundation.dart';

import '../../features/auth/signed_in_customer.dart';
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
  AppController({List<Appointment>? appointments, bool notificationsPreview = true})
      : appointments = List<Appointment>.of(
          appointments ?? SampleAppointments.seed(),
        ),
        _notificationsPreview = notificationsPreview;

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

  bool get notificationsPreview => _notificationsPreview;

  List<Appointment> get upcoming => appointments
      .where((appointment) =>
          appointment.status == AppointmentStatus.confirmed ||
          appointment.status == AppointmentStatus.pending)
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  List<Appointment> get past => appointments
      .where((appointment) => appointment.status == AppointmentStatus.completed)
      .toList()
    ..sort((a, b) => b.start.compareTo(a.start));

  void setTab(int index) {
    if (tabIndex == index) return;
    tabIndex = index;
    notifyListeners();
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
    notifyListeners();
    refreshCatalogue();
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
      catalog = SalonCatalog.emptyLive;
      catalogError = error.statusCode == 401
          ? 'Sign in again to load the salon catalogue.'
          : error.message;
    } catch (_) {
      catalog = SalonCatalog.emptyLive;
      catalogError = 'Cannot reach the salon server.';
    }
    catalogLoading = false;
    notifyListeners();
  }

  void signOut() {
    signedIn = null;
    catalog = SalonCatalog.preview;
    catalogLoading = false;
    catalogError = null;
    notifyListeners();
  }

  void setNotificationsPreview(bool value) {
    if (_notificationsPreview == value) return;
    _notificationsPreview = value;
    notifyListeners();
  }
}
