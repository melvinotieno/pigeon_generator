# pigeon_generator

This is a dart package that integrates [build_runner](https://pub.dev/packages/build_runner) with [pigeon](https://pub.dev/packages/pigeon) code generator for platform channels. This automates the manual process of running `pigeon` hence making it easier and efficient to generate the code for platform channels.

[![pub package](https://img.shields.io/pub/v/pigeon_generator.svg)](https://pub.dev/packages/pigeon_generator)
[![pub points](https://img.shields.io/pub/points/pigeon_generator?color=2E8B57&label=pub%20points)](https://pub.dev/packages/pigeon_generator/score)

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
  options:
    source_out: "path/to/source"
    test_out: "path/to/test"
    copyright_header: ["Copyright Header"]
objc:
  header_out: "macos/Runner"
  source_out: "macos/Runner"
  options:
    header_include: "path/to/include"
    prefix: "PGN"
    copyright_header: ["Copyright Header"]
java:
  out: "android/app/src/main/java/com/example/pigeon_generator_example"
  options:
    package: "com.example.pigeon_generator_example"
    copyright_header: ["Copyright Header"]
    use_generated_annotation: true
swift:
  out: "ios/Runner"
  options:
    copyright_header: ["Copyright Header"]
    include_error_class: true
kotlin:
  out: "android/app/src/main/kotlin/com/example/pigeon_generator_example"
  options:
    package: "com.example.pigeon_generator_example"
    copyright_header: ["Copyright Header"]
    include_error_class: true
cpp:
  header_out: "windows/runner"
  source_out: "windows/runner"
  options:
    header_include: "path/to/include"
    namespace: "pigeon_generator_example"
    copyright_header: ["Copyright Header"]
    header_out: "path/to/out"
gobject:
  header_out: "linux"
  source_out: "linux"
  options:
    header_include: "path/to/include"
    module: "pigeon_generator_example"
    copyright_header: ["Copyright Header"]
    header_out: "path/to/out"
ast:
  out: "output"
copyright_header: "pigeons/copyright.txt"
debug_generators: false
base_path: "pigeon_generator_example"
skip_outputs:
  defaults: [objc] # Do not generate output for objc for pigeons/defaults.dart
out_folder: "pigeons"
out_template: "name.g.extension"
```

- `inputs`: The folder path where the pigeon files are located. Default is `pigeons`.
- `dart`: Dart code generation configuration. Defaults will be used if not specified, and disabled if `false`.
  - `out`: The folder path where the dart code will be generated `(.dart)`. If not defined, this defaults to `lib`.
  - `test_out`: The folder path where the dart test code will be generated `(_test.dart)`. If the value is `true` or `test` directory exists, this defaults to `test`.
  - `package_name`: The name of the package the pigeon files will be used in.
  - `options`:
    - `source_out`: The folder path where the dart source files will be generated.
    - `test_out`: The folder path where the dart test files will be generated.
    - `copyright_header`: A copyright header that will get prepended to generated code.
- `objc`: Objective-C code generation configuration. Defaults will be used if the value is `true`.
  - `header_out`: The folder path where the Objective-C header files will be generated `(.h)`. Default is `macos/Runner`.
  - `source_out`: The folder path where the Objective-C source files will be generated `(.m)`. Default is `macos/Runner`.
  - `options`:
    - `header_include`: The folder path to the header that will get placed in the source file.
    - `prefix`: Prefix that will be appended before all generated classes and protocols.
    - `copyright_header`: A copyright header that will get prepended to generated code.
- `java`: Java code generation configuration for Android. Defaults will only be used if the value is `true`.
  - `out`: The folder path where the Java code will be generated `(.java)`.
  - `options`:
    - `package`: The package where the generated class will live.
    - `copyright_header`: A copyright header that will get prepended to generated code.
    - `use_generated_annotation`: Determines if the javax.annotation.Generated is used in the output. This is false by default since that dependency isn't available in plugins by default.
- `swift`: Swift code generation configuration. Defaults will be used if the value is `true` or if `ios` directory exists.
  - `out`: The folder path where the Swift code will be generated `(.swift)`. Default is `ios/Runner`.
  - `options`:
    - `copyright_header`: A copyright header that will get prepended to generated code.
    - `include_error_class`: Whether to include the error class in generation. This should only ever be set to false if you have another generated Swift file in the same directory.
- `kotlin`: Kotlin code generation configuration for Android. Defaults will be used if the value is `true` or if it is not specified and android folder exists.
  - `out`: The folder path where the Kotlin code will be generated `(.kt)`. For the default, we get the applicationId from `android/app/build.gradle` and use it to generate the path.
  - `options`:
    - `package`: The package where the generated class will live.
    - `copyright_header`: A copyright header that will get prepended to generated code.
    - `include_error_class`: Whether to include the error class in generation. This should only ever be set to false if you have another generated Kotlin file in the same directory.
- `cpp`: C++ code generation configuration for Windows. Defaults will be used if the value is `true` or if `windows` directory exists.
  - `header_out`: The folder path where the C++ header files will be generated `(.h)`. Default is `windows/runner`.
  - `source_out`: The folder path where the C++ source files will be generated `(.cpp)`. Default is `windows/runner`.
  - `options`:
    - `header_include`: The folder path to the header that will get placed in the source file.
    - `namespace`: The namespace where the generated class will live.
    - `copyright_header`: A copyright header that will get prepended to generated code.
    - `header_out`: The folder path to the output header file location.
- `gobject`: GObject code generation configuration for Linux. Defaults will be used if the value is `true` or if `linux` directory exists.
  - `header_out`: The folder path where the GObject header files will be generated `(.h)`. Default is `linux`.
  - `source_out`: The folder path where the GObject source files will be generated `(.cc)`. Default is `linux`.
  - `options`:
    - `header_include`: The folder path to the header that will get placed in the source file.
    - `module`: The module where the generated class will live.
    - `copyright_header`: A copyright header that will get prepended to generated code.
    - `header_out`: The folder path to the output header file location.
- `ast`: AST code generation configuration. Defaults will only be used if the value is `true`.
  - `out`: The folder path where the AST code will be generated `(.ast)`. Default is `ast`.
- `copyright_header`: The path to the file containing the copyright header. If the copyright header is placed inside the same folder as the pigeon files, then you do not need to specify this option as the generator will automatically pick it.
- `debug_generators`: The value `true` prints the line number of the generator in comments at new lines.
- `base_path`: A base path to be prepended to all provided output paths.
- `skip_outputs`: The platforms to skip generating outputs for. Options include: `dart`, `dart_test`, `java`, `kotlin`, `swift`, `objc`, `cpp`, `gobject`, `ast`.
- `out_folder`: The folder that will be appended to all output paths.
- `out_template`: The template for the generated file name. The default is `name.g.extension` where `name` is the name of the pigeon file and `extension` is the platform specific extension. Example for the pigeon file named `test.dart`, the generated file for kotlin will be `Test.g.kt`.

### 3. Run the generator

To generate the code, run the following command:

```bash
dart run build_runner build
```

You can use the watch mode to automatically regenerate the code when the pigeon files change:

```bash
dart run build_runner watch
```
