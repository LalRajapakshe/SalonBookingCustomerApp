import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/core/api/api_exception.dart';
import 'package:salon_customer_app/core/state/app_controller.dart';
import 'package:salon_customer_app/core/state/app_scope.dart';
import 'package:salon_customer_app/features/auth/customer_session_store.dart';
import 'package:salon_customer_app/features/auth/signed_in_customer.dart';
import 'package:salon_customer_app/features/booking/data/customer_booking_api.dart';
import 'package:salon_customer_app/features/catalog/data/customer_catalogue_api.dart';
import 'package:salon_customer_app/features/catalog/data/salon_catalog.dart';
import 'package:salon_customer_app/features/feedback/data/feedback_api.dart';
import 'package:salon_customer_app/features/feedback/screens/feedback_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pending = PendingFeedback(
    appointmentServiceId: 15,
    serviceName: 'Cut and finish',
    stylistName: 'Nimal Perera',
    appointmentDate: '2026-11-25',
  );

  Future<void> pumpGate(
    WidgetTester tester,
    AppController app, {
    required Future<List<PendingFeedback>> Function(String token) loadPending,
    Future<void> Function(String token, PendingFeedback item, int rating, String comment)? submitFeedback,
  }) async {
    await tester.pumpWidget(
      AppScope(
        controller: app,
        child: MaterialApp(
          home: FeedbackGate(
            loadPending: loadPending,
            submitFeedback: submitFeedback,
            child: const Text('Home content'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('pending feedback blocks home, keeps account, and survives a failed submit', (tester) async {
    final app = _quiet()..signIn(_customer());
    var submits = 0;
    await pumpGate(
      tester,
      app,
      loadPending: (_) async => const [pending],
      submitFeedback: (_, __, ___, ____) async {
        submits++;
        throw const ApiException('Cannot reach the salon server.');
      },
    );

    expect(find.text('Home content'), findsNothing);
    expect(find.text('Cut and finish with Nimal Perera'), findsOneWidget);
    expect(find.text('2026-11-25'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Home content'), findsOneWidget);

    app.setTab(AppTab.home);
    await tester.pumpAndSettle();
    expect(find.text('Feedback required'), findsOneWidget);

    await tester.tap(find.text('Submit feedback'));
    await tester.pumpAndSettle();
    expect(submits, 1);
    expect(find.text('Cannot reach the salon server.'), findsOneWidget);
    expect(find.text('Cut and finish with Nimal Perera'), findsOneWidget);
    expect(app.signedIn, isNotNull);
  });

  testWidgets('an expired session leaves the feedback gate instead of trapping the customer', (tester) async {
    final app = _quiet()..signIn(_customer());
    await pumpGate(
      tester,
      app,
      loadPending: (_) async => throw const ApiException('Sign in again.', statusCode: 401),
    );

    expect(find.text('Feedback required'), findsNothing);
    expect(find.text('Home content'), findsOneWidget);
    expect(app.signedIn, isNull);
  });

  testWidgets('saved feedback confirms and then restores navigation', (tester) async {
    final app = _quiet()..signIn(_customer());
    var remaining = const [pending];
    await pumpGate(
      tester,
      app,
      loadPending: (_) async => remaining,
      submitFeedback: (_, item, rating, comment) async {
        expect(item.appointmentServiceId, 15);
        expect(rating, 4);
        expect(comment, 'Careful finish');
        remaining = const [];
      },
    );

    await tester.tap(find.text('5 stars'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4 stars').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Careful finish');
    await tester.tap(find.text('Submit feedback'));
    await tester.pumpAndSettle();

    expect(find.text('Feedback saved.'), findsOneWidget);
    expect(find.text('Home content'), findsNothing);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Home content'), findsOneWidget);
  });

  test('a saved session is restored until sign-out and an expired session is dropped', () async {
    final store = MemoryCustomerSessionStore();
    final app = _quiet(store)..signIn(_customer());
    expect(store.saved?.username, 'maya');

    final restored = _quiet(store);
    await restored.restoreSession();
    expect(restored.signedIn?.accessToken, 'token');

    restored.signOut();
    expect(store.saved, isNull);
    expect(restored.signedIn, isNull);

    store.saved = _customer(expiresAt: DateTime.now().subtract(const Duration(minutes: 1)));
    final expired = _quiet(store);
    await expired.restoreSession();
    expect(expired.signedIn, isNull);
    expect(store.saved, isNull);
  });
}

AppController _quiet([CustomerSessionStore? store]) {
  return AppController(appointments: const [], sessionStore: store)
    ..catalogueApi = _QuietCatalogue()
    ..bookingApi = _QuietBookings();
}

class _QuietCatalogue extends CustomerCatalogueApi {
  @override
  Future<SalonCatalog> load(String accessToken) async => SalonCatalog.emptyLive;
}

class _QuietBookings extends CustomerBookingApi {
  @override
  Future<List<CustomerAppointmentRecord>> list({required String accessToken}) async => const [];
}

SignedInCustomer _customer({DateTime? expiresAt}) {
  return SignedInCustomer(
    accessToken: 'token',
    username: 'maya',
    fullName: 'Maya Fernando',
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 2)),
    customerId: 7,
  );
}
