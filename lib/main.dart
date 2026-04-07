import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_zone;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'core/services/notification_service.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/budget_savings_debt_providers.dart';
import 'providers/sub_category_provider.dart';
import 'providers/credit_card_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

<<<<<<< HEAD
  // Init notifications safely — don't crash app if this fails
  try {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Create notification channel (required for Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'myfinance_main_channel',
      'MyFinance Notifications',
      description: 'Budget alerts and daily reminders',
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    debugPrint('Notification init error (non-fatal): $e');
  }
=======
  // Timezone initialization (required for scheduled notifications)
  tz.initializeTimeZones();
  try {
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz_zone.setLocalLocation(tz_zone.getLocation(localTz));
  } catch (_) {
    tz_zone.setLocalLocation(tz_zone.getLocation('UTC'));
  }

  // Notification setup
  await NotificationService.init();
>>>>>>> 98623ae (updating with some fixes and cc pages)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => CreditCardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
