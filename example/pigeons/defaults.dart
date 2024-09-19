import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class DefaultsApi {
  @async
  void sendMessage(String message);
}
