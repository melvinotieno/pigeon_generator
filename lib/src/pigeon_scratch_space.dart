import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/pigeon.dart';
import 'package:scratch_space/scratch_space.dart';

/// A specialized [ScratchSpace] for handling Pigeon generated files.
class PigeonScratchSpace extends ScratchSpace {
  @override
  File fileFor(AssetId id) {
    final packagePath = path.url.join('package', id.package, id.path);

    return File(path.join(tempDir.path, path.normalize(packagePath)));
  }

  /// Returns [PigeonOptions] with the out paths updated to the scratch space.
  ///
  /// - [pigeonOptions]: The original [PigeonOptions] object.
  /// - [allowedOutputs]: An iterable of [AssetId] objects representing the
  ///   allowed output files.
  PigeonOptions getPigeonOptions(
    PigeonOptions pigeonOptions,
    Iterable<AssetId> allowedOutputs,
  ) {
    final oldPigeonOptions = pigeonOptions;

    String? getPath(String? output) {
      if (output == null) return null;

      final assetId = allowedOutputs.firstWhere(
        (allowedOutput) => allowedOutput.path == output,
      );

      return fileFor(assetId).path;
    }

    final newPigeonOptions = PigeonOptions(
      dartOut: getPath(pigeonOptions.dartOut),
      dartTestOut: getPath(pigeonOptions.dartTestOut),
      cppHeaderOut: getPath(pigeonOptions.cppHeaderOut),
      cppSourceOut: getPath(pigeonOptions.cppSourceOut),
      gobjectHeaderOut: getPath(pigeonOptions.gobjectHeaderOut),
      gobjectSourceOut: getPath(pigeonOptions.gobjectSourceOut),
      kotlinOut: getPath(pigeonOptions.kotlinOut),
      javaOut: getPath(pigeonOptions.javaOut),
      swiftOut: getPath(pigeonOptions.swiftOut),
      objcHeaderOut: getPath(pigeonOptions.objcHeaderOut),
      objcSourceOut: getPath(pigeonOptions.objcSourceOut),
      astOut: getPath(pigeonOptions.astOut),
    );

    return oldPigeonOptions.merge(newPigeonOptions);
  }
}
