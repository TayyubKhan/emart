import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  late String address;

  @HiveField(1)
  late String body;

  Message({required this.address, required this.body});
}
