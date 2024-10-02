import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/overrides.g.dart',
))
@HostApi()
abstract class OverridesApi {
  @async
  void sendMessage(String message);
}
