# salon_customer_app

Customer-facing Flutter app for booking salon visits. It is a separate project from the staff ERP in `salon_booking_mobile` and does not call the Salon Booking API.

Phase 1 is a local preview. Services, stylists, studios, prices, availability, and the sample past visit all come from mock data in the app. A booking confirmed in the app is kept in memory for the current session and shows up under My Bookings. It is not sent to a salon, saved in a database, or kept after the app closes.

## What you can do

- Browse the home page, categories, services, stylists, studios, and offers.
- Search and filter services on Discover.
- Open a service and walk through stylist, date, time, review, and confirmation.
- See the confirmed visit on the Upcoming tab.
- Open a sample completed visit on the Past tab.
- Review the preview profile. Account, payment, and sign-in actions are labeled as unavailable.

Currency is defined once on `MockCatalog.currency` (`LKR`, displayed as `Rs`).

## Run locally

```bash
cd salon_customer_app
flutter pub get
flutter run
```

## Checks

```bash
flutter analyze
flutter test
```

## Not in this phase

- Customer sign-in or account changes
- Live availability, payments, SMS, or push reminders
- API or database access
- Cancelling or rescheduling a visit
- Keeping bookings after the app restarts
