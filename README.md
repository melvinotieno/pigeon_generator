# pigeon_generator

This is a dart package that integrates [build_runner](https://pub.dev/packages/build_runner) with [pigeon](https://pub.dev/packages/pigeon) code generator for platform channels. This automates the manual process of running `pigeon` hence making it easier and efficient to generate the code for platform channels.

<div>
  <a href="https://pub.dev/packages/pigeon_generator">
    <img alt="pub.dev" src="https://img.shields.io/pub/v/pigeon_generator"/>
  </a>
</div>

## Installation

To install this package, run the following command:

```bash
flutter pub add build_runner pigeon pigeon_generator --dev
```

Alternatively, add the following dependencies to your `pubspec.yaml` file, replacing `[version]` with the latest version of the package:

```yaml
dev_dependencies:
  build_runner: [version]
  pigeon: [version]
  pigeon_generator: [version]
```

## Usage

Follow the steps below to use `pigeon_generator` in your project:

### 1. Create a pigeons folder

Create a folder named `pigeons` in the root of your project. This folder will contain all the pigeon files.

You willl also need to include this folders in the `build.yaml` file so that the `build_runner` can pick up the pigeon files.

```yaml
additional_public_assets:
  - pigeons/**
```

You may use a different folder other than `pigeons` but you will need to update the `build.yaml` file accordingly. If you are using a different folder, you will have to specify that folder in the `build.yaml` file options for the `pigeon_generator` builder. Example is as shown below:

```yaml
targets:
  $default:
    builders:
      pigeon_generator:
        options:
          inputs: pigeons_other

additional_public_assets:
  - pigeons_other/**
```

### 2. Configuring pigeon_generator

By default, you do not need to do anything other than creating the pigeons folder with the pigeon files and specifying the folder in the `additional_public_assets` of the `build.yaml` file.

However, a full list of the configurations you can set is shown below:

```yaml
inputs: pigeons
dart:
  out: "lib"
  test_out: "test"
  package_name: "pigeon_generator_example"
cpp:
  header_out: "windows/runner"
  source_out: "windows/runner"
  namespace: "pigeon_generator_example"
gobject:
  header_out: "linux"
  source_out: "linux"
  module: "pigeon_generator_example"
kotlin:
  out: "android/app/src/main/kotlin/com/example/pigeon_generator_example"
  package: "com.example.pigeon_generator_example"
java:
  out: "android/app/src/main/java/com/example/pigeon_generator_example"
  package: "com.example.pigeon_generator_example"
  use_generated_annotation: true
swift:
  out: "ios/Runner"
objc:
  header_out: "macos/Runner"
  source_out: "macos/Runner"
  prefix: "PGN"
ast:
  out: "output"
copyright_header: "pigeons/copyright.txt"
one_language: false
debug_generators: false
base_path: "pigeon_generator_example"
out_template: "name.g.extension"
```

- `inputs`: The folder path where the pigeon files are located. Default is `pigeons`.
- `dart`: Dart code generation configuration.
  - `out`: The folder path where the dart code will be generated `(.dart)`. If `one_language` is not defined or is false, this defaults to `lib/pigeons` if not specified.
  - `test_out`: The folder path where the dart test code will be generated `(_test.dart)`. If the value is `true`, this defaults to `test/pigeons`.
  - `package_name`: The package name of the generated dart code.
- `cpp`: C++ code generation configuration for Windows. Defaults will be used if the value is `true` or if it is not specified and windows folder exists.
  - `header_out`: The folder path where the C++ header files will be generated `(.h)`. Default is `windows/runner/pigeons`.
  - `source_out`: The folder path where the C++ source files will be generated `(.cpp)`. Default is `windows/runner/pigeons`.
  - `namespace`: The namespace of the generated C++ code.
- `gobject`: GObject code generation configuration for Linux. Defaults will be used if the value is `true` or if it is not specified and linux folder exists.
  - `header_out`: The folder path where the GObject header files will be generated `(.h)`. Default is `linux/pigeons`.
  - `source_out`: The folder path where the GObject source files will be generated `(.cc)`. Default is `linux/pigeons`.
  - `module`: The module name of the generated GObject code.
- `kotlin`: Kotlin code generation configuration for Android. Defaults will be used if the value is `true` or if it is not specified and android folder exists.
  - `out`: The folder path where the Kotlin code will be generated `(.kt)`. For the default, we get the applicationId from `android/app/build.gradle` and use it to generate the path.
  - `package`: The package name of the generated Kotlin code.
- `java`: Java code generation configuration for Android. Defaults will only be used if the value is `true`.
  - `out`: The folder path where the Java code will be generated `(.java)`.
  - `package`: The package name of the generated Java code.
  - `use_generated_annotation`: The value `true` adds the java.annotation.Generated annotation to the output.
- `swift`: Swift code generation configuration for iOS. Defaults will be used if the value is `true` or if it is not specified and ios folder exists.
  - `out`: The folder path where the Swift code will be generated `(.swift)`. Default is `ios/Runner/pigeons`.
- `objc`: Objective-C code generation configuration for macOS. Defaults will be used if the value is `true` or if it is not specified and macos folder exists.
  - `header_out`: The folder path where the Objective-C header files will be generated `(.h)`. Default is `macos/Runner/pigeons`.
  - `source_out`: The folder path where the Objective-C source files will be generated `(.m)`. Default is `macos/Runner/pigeons`.
  - `prefix`: The prefix of the generated Objective-C code.
- `ast`: AST code generation configuration. Defaults will only be used if the value is `true`.
  - `out`: The folder path where the AST code will be generated `(.ast)`. Default is `output`.
- `copyright_header`: The path to the file containing the copyright header. If the copyright header is placed inside the same folder as the pigeon files, then you do not need to specify this option as the generator will automatically pick it.
- `one_language`: The value `true` allow Pigeon to only generate code for one language. Default is `false`.
- `debug_generators`: The value `true` prints the line number of the generator in comments at new lines. Default is `false`.
- `base_path`: A base path to be prefixed to all outputs and copyright header path. Generally used for testing.
- `out_template`: The template for the generated file name. The default is `name.g.extension` where `name` is the name of the pigeon file and `extension` is the platform specific extension. Example for the pigeon file named `test.dart`, the generated file for kotlin will be `Test.g.kt`.

### 3. Run the generator

To generate the code, run the following command:

```bash
dart run build_runner build
```
