## 2.0.5

- Support for android library projects. The generator will attempt to find package name from android/build.gradle (assuming it is a library project), if android/app/build.gradle is not found.

## 2.0.4

- Fix null pointer exception when dart config is not set in build.yaml.
- Reimplement errorClassName for Kotlin removed in the previous version.

## 2.0.3

- Added support for options, i.e. for dart, DartOptions, for kotlin, KotlinOptions etc. This means settings such as module for gobject, package for android and java etc will move to options. See [build.example.yaml](example/build.example.yaml) for more details.
- Ability to override the options for specific input files by using ConfigurePigeon annotation provided by Pigeon.
- Add a default prefix `Pigeon` for Objective-C code generation.

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
