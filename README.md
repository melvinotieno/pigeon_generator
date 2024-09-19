# pigeon_generator

Pigeon Generator is a dart package that integrates [build_runner](https://pub.dev/packages/build_runner) with [pigeon](https://pub.dev/packages/pigeon) code generator for platform channels. This automates the manual process of running `pigeon` hence making it easier and efficient to generate the code for platform channels.

<div>
  <a href="https://pub.dev/packages/pigeon_generator">
    <img alt="pub.dev" src="https://img.shields.io/pub/v/pigeon_generator"/>
  </a>
</div>

## Installation

To install this package, run the following command:

```bash
flutter pub add pigeon pigeon_generator --dev
```

Alternatively, add the following dependencies to your `pubspec.yaml` file, replacing `[version]` with the latest version of the package:

```yaml
dev_dependencies:
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

You may use a different folder other than `pigeons` but you will need to update the `build.yaml` file accordingly. Also, you will have to specify that folder in the `pigeon.yaml`. This is shown in step [3. More configuration](#3-more-configuration).

### 2. Configuring pigeon_generator

By default, you do not need to do anything else after completing the above step. However, the generator will automatically generate dart code only. To tell the generator to generate code for other platforms, in the `build.yaml` file, add the following configuration:

```yaml
targets:
  $default:
    builders:
      pigeon_generator:
        options:
          platforms:
            - android:kotlin
            - ios
```

Of course you can specify only the platforms you need. The available platforms are `android:kotlin`, `android:java`, `ios`, `macos`, `linux`, and `windows`.

You can also tell the generator to generate ast code, dart test code and to print the line number of the generator in comments at new lines.

The full configuration is shown below:

```yaml
targets:
  $default:
    builders:
      pigeon_generator:
        options:
          platforms:
            - android:kotlin
            - ios
          ast: true
          dart_test: true
          debug_generators: true
```

### 3. More configuration

If the above configuration is not enough and you want more control over the generator, you can create a `pigeon.yaml` file in the root of your project. This file will contain the configuration for the generator.

The available configuration options are:

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
```

- `inputs`: The folder path where the pigeon files are located. Default is `pigeons`.
- `dart`: Dart code generation configuration.
  - `out`: The folder path where the dart code will be generated `(.dart)`. Required if one_language is not specified.
  - `test_out`: The folder path where the dart test code will be generated `(_test.dart)`.
  - `package_name`: The package name of the generated dart code.
- `cpp`: C++ code generation configuration for Windows.
  - `header_out`: The folder path where the C++ header files will be generated `(.h)`.
  - `source_out`: The folder path where the C++ source files will be generated `(.cpp)`.
  - `namespace`: The namespace of the generated C++ code.
- `gobject`: GObject code generation configuration for Linux.
  - `header_out`: The folder path where the GObject header files will be generated `(.h)`.
  - `source_out`: The folder path where the GObject source files will be generated `(.cc)`.
  - `module`: The module name of the generated GObject code.
- `kotlin`: Kotlin code generation configuration for Android.
  - `out`: The folder path where the Kotlin code will be generated `(.kt)`.
  - `package`: The package name of the generated Kotlin code.
- `java`: Java code generation configuration for Android.
  - `out`: The folder path where the Java code will be generated `(.java)`.
  - `package`: The package name of the generated Java code.
  - `use_generated_annotation`: The value `true` adds the java.annotation.Generated annotation to the output.
- `swift`: Swift code generation configuration for iOS.
  - `out`: The folder path where the Swift code will be generated `(.swift)`.
- `objc`: Objective-C code generation configuration for macOS.
  - `header_out`: The folder path where the Objective-C header files will be generated `(.h)`.
  - `source_out`: The folder path where the Objective-C source files will be generated `(.m)`.
  - `prefix`: The prefix of the generated Objective-C code.
- `ast`: AST code generation configuration.
  - `out`: The folder path where the AST code will be generated `(.ast)`.
- `copyright_header`: The path to the file containing the copyright header. If the copyright header is placed inside the same folder as the pigeon files, then you do not need to specify this option as the generator will automatically pick it.
- `one_language`: The value `true` allow Pigeon to only generate code for one language. Default is `false`.
- `debug_generators`: The value `true` prints the line number of the generator in comments at new lines. Default is `false`.
- `base_path`: A base path to be prefixed to all outputs and copyright header path. Generally used for testing.

The generated files will be named according to the pigeon file name and the extension replaced with the corresponding platform extension automatically.

### 4. Run the generator

To generate the code, run the following command:

```bash
dart run build_runner build
```
