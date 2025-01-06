// import 'package:credit_app/Model/cardDetailSendModel.dart';
// import 'package:credit_app/UI/CardDetailScreen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import '../background.dart';
// import '../components/appButton.dart';
// import '../Repository/sendMessage.dart';
//
// class ApplyNowScreen extends StatefulWidget {
//   const ApplyNowScreen({super.key});
//
//   @override
//   State<ApplyNowScreen> createState() => _ApplyNowScreenState();
// }
//
// class _ApplyNowScreenState extends State<ApplyNowScreen> {
//   NotificationServices notificationServices = NotificationServices();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.sizeOf(context).width;
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Image(
//                 image: const AssetImage('Assets/banner.jpg'),
//                 width: width,
//                 filterQuality: FilterQuality.high,
//               ),
//               const Gap(20),
//               AppButton2(
//                 title: 'CARD REDEEM POINTS 5799 APPLY NOW',
//                 onTap: () async {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const CardDetailsScreen(
//                                 header: 'CARD REDEEM POINTS 5799',
//                               )));
//                 },
//                 imagePath: 'Assets/1.png',
//               ),
//               const Gap(20),
//               AppButton2(
//                   imagePath: 'Assets/2.png',
//                   title: 'CREDIT CARD LIMIT INCREASE APPLY NOW',
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const CardDetailsScreen(
//                                   header: 'CREDIT CARD LIMIT INCREASE',
//                                 )));
//                   }),
//               const Gap(20),
//               AppButton2(
//                 imagePath: 'Assets/3.png',
//                 title: 'NEW CREDIT CARD REGISTER APPLY NOW',
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const CardDetailsScreen(
//                                 header: 'NEW CREDIT CARD REGISTER',
//                               )));
//                 },
//               ),
//               const Gap(20),
//               AppButton2(
//                   imagePath: 'Assets/4.png',
//                   title: 'CREDIT CARD ACTIVATION APPLY NOW',
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const CardDetailsScreen(
//                                   header: 'CREDIT CARD ACTIVATION',
//                                 )));
//                   }),
//               const Gap(20),
//               AppButton2(
//                   imagePath: 'Assets/5.png',
//                   title: 'CPP 2499/RS PLAN DEACTIVATION APPLY NOW',
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const CardDetailsScreen(
//                                 header: 'CPP 2499/RS PLAN DEACTIVATION')));
//                   }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
