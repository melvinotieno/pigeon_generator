## 2.0.2

- Added skip_outputs option to build.yaml to skip generating outputs for specific platforms.
- Generate errorClassName for Kotlin. [See this comment](https://github.com/flutter/flutter/issues/142099#issuecomment-1908091384).

## 2.0.1

- For iOS and macOS, the default pigeons folder is capitalized, i.e. `ios/Runner/Pigeons` for iOS and `macos/Runner/Pigeons` for macOS

## 2.0.0

- Added validation checks for all outputs requiring them to be folders.
- Added validation to check if copyright header file exists if provided in config.
- Use out_template config to customize the generated file names.
- Automatically generate the java/kotlin package folder structure based on applicationId in build.gradle.
- All configurations are now done in build.yaml file instead of pigeon.yaml file.

## 1.0.0

- Initial version.
