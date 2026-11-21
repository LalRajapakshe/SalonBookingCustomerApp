import 'package:flutter/material.dart';

import '../../features/ai_hair_studio/screens/hair_studio_screen.dart';
import '../../features/beauty_inspiration/screens/inspiration_detail_screen.dart';
import '../../features/beauty_inspiration/screens/inspiration_gallery_screen.dart';
import '../../features/beauty_inspiration/screens/wishlist_screen.dart';
import '../../features/booking/models/appointment.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/booking/screens/booking_flow_screen.dart';
import '../../features/services/screens/service_detail_screen.dart';
import '../../features/smart_booking_calendar/models/demo_booking.dart';
import '../../features/smart_booking_calendar/screens/demo_booking_review_screen.dart';
import '../../features/smart_booking_calendar/screens/demo_booking_success_screen.dart';
import '../../features/smart_booking_calendar/screens/smart_calendar_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

class AppNavigation {
  AppNavigation._();

  static Route<void> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.service => ServiceDetailScreen(
          serviceId: settings.arguments as String,
        ),
      AppRoutes.booking => BookingFlowScreen(
          initialServiceId: settings.arguments as String?,
        ),
      AppRoutes.confirmation => BookingConfirmationScreen(
          appointment: settings.arguments! as Appointment,
        ),
      AppRoutes.aiHairStudio => const HairStudioScreen(),
      AppRoutes.inspiration => const InspirationGalleryScreen(),
      AppRoutes.inspirationDetail => InspirationDetailScreen(
          lookId: settings.arguments as String,
        ),
      AppRoutes.wishlist => const WishlistScreen(),
      AppRoutes.smartCalendar => SmartCalendarScreen(
          initialServiceId: settings.arguments as String?,
        ),
      AppRoutes.smartCalendarReview => const DemoBookingReviewScreen(),
      AppRoutes.smartCalendarConfirmed => DemoBookingSuccessScreen(
          booking: settings.arguments! as DemoBooking,
        ),
      _ => const AppShell(),
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => page,
    );
  }
}
