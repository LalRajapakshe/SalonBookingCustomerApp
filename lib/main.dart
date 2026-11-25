import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/customer_session_store.dart';

void main() {
  runApp(const SalonCustomerApp(sessionStore: PreferencesCustomerSessionStore()));
}
