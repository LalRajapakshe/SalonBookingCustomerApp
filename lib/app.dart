import 'package:flutter/material.dart';

import 'core/navigation/app_navigation.dart';
import 'core/state/app_controller.dart';
import 'core/state/app_scope.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_dimensions.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_hair_studio/state/hair_studio_bindings.dart';
import 'features/ai_hair_studio/state/hair_studio_scope.dart';
import 'features/beauty_inspiration/state/wishlist_controller.dart';
import 'features/beauty_inspiration/state/wishlist_scope.dart';
import 'features/auth/customer_session_store.dart';
import 'features/auth/login_screen.dart';
import 'features/smart_booking_calendar/state/calendar_controller.dart';
import 'features/smart_booking_calendar/state/calendar_scope.dart';
import 'core/navigation/app_shell.dart';

class SalonCustomerApp extends StatefulWidget {
  const SalonCustomerApp({
    this.controller,
    this.sessionStore,
    this.hairStudio,
    this.requireLogin = true,
    super.key,
  });

  final AppController? controller;
  final CustomerSessionStore? sessionStore;
  final HairStudioBindings? hairStudio;

  /// The running app opens on sign-in. Tests can skip that gate.
  final bool requireLogin;

  @override
  State<SalonCustomerApp> createState() => _SalonCustomerAppState();
}

class _SalonCustomerAppState extends State<SalonCustomerApp> {
  late final AppController _controller = widget.controller ?? AppController(sessionStore: widget.sessionStore);
  late final bool _ownsController = widget.controller == null;
  late bool _restoring = widget.controller == null && widget.sessionStore != null;
  late final HairStudioBindings _hairStudio =
      widget.hairStudio ?? HairStudioBindings.production();
  late final bool _ownsHairStudio = widget.hairStudio == null;
  late final WishlistController _wishlist = WishlistController();
  late final CalendarController _calendar = CalendarController();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    if (!_restoring) return;
    try {
      await _controller.restoreSession();
    } catch (_) {
      await widget.sessionStore?.clear();
    }
    if (mounted) setState(() => _restoring = false);
  }

  @override
  void dispose() {
    _wishlist.dispose();
    _calendar.dispose();
    if (_ownsHairStudio) {
      _hairStudio.dispose();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lumière',
        theme: AppTheme.light,
        home: _restoring
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : _StartGate(requireLogin: widget.requireLogin),
        onGenerateRoute: AppNavigation.onGenerateRoute,
        builder: (context, child) {
          return WishlistScope(
            controller: _wishlist,
            child: CalendarScope(
              controller: _calendar,
              child: HairStudioScope(
                bindings: _hairStudio,
                child: ColoredBox(
                  color: AppColors.scaffoldBackground,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.maxContentWidth,
                      ),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StartGate extends StatelessWidget {
  const _StartGate({required this.requireLogin});

  final bool requireLogin;

  @override
  Widget build(BuildContext context) {
    final signedIn = AppScope.of(context).signedIn;
    if (requireLogin && signedIn == null) {
      return const LoginScreen();
    }
    return const AppShell();
  }
}
