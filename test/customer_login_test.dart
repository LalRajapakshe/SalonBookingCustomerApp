import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_customer_app/app.dart';
import 'package:salon_customer_app/core/navigation/app_shell.dart';
import 'package:salon_customer_app/core/state/app_controller.dart';
import 'package:salon_customer_app/core/state/app_scope.dart';
import 'package:salon_customer_app/shared/widgets/app_primary_button.dart';
import 'package:salon_customer_app/features/auth/customer_auth_api.dart';
import 'package:salon_customer_app/features/auth/login_screen.dart';
import 'package:salon_customer_app/features/auth/signed_in_customer.dart';
void main() {
  testWidgets('the app opens on the sign-in screen', (tester) async {
    await tester.pumpWidget(const SalonCustomerApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('profile opens the sign-in form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = AppController()..tabIndex = AppTab.profile;
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AppShell()),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(AppPrimaryButton, 'Sign in'));
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('a customer login is kept and can be signed out', (tester) async {
    final controller = AppController();
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LoginScreen(auth: _ScriptedAuth()),
                      ),
                    );
                  },
                  child: const Text('Open sign in'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login-username')), 'maya');
    await tester.enterText(find.byKey(const Key('login-password')), 'secret');
    await tester.tap(find.widgetWithText(AppPrimaryButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(controller.signedIn?.fullName, 'Maya Fernando');
    expect(controller.signedIn?.customerId, 4);

    controller.tabIndex = AppTab.profile;
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(
          key: ValueKey('signed-in-profile'),
          home: AppShell(),
        ),
      ),
    );
    expect(find.text('Maya Fernando'), findsWidgets);
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pump();
    expect(controller.signedIn, isNull);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

class _ScriptedAuth extends CustomerAuthApi {
  @override
  Future<SignedInCustomer> login({
    required String username,
    required String password,
    String? tenantCode,
  }) async {
    return SignedInCustomer(
      accessToken: 'token',
      username: username,
      fullName: 'Maya Fernando',
      expiresAt: DateTime(2026, 10, 25),
      customerId: 4,
    );
  }
}
