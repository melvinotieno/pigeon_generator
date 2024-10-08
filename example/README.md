Below is an example of a build.yaml file that can be used to generate pigeons.

```yaml
targets:
  $default:
    builders:
      pigeon_generator:
        options:
          inputs: pigeons # Default
          dart:
            out: "lib" # Defaults to lib/pigeons if one_language is not set or false
            test_out: "test" # Or true/false
            package_name: "pigeon_generator_example"
          cpp: # Or true/false
            header_out: "windows/runner"
            source_out: "windows/runner"
            options:
              namespace: "pigeon_generator_example"
          gobject: # Or true/false
            header_out: "linux"
            source_out: "linux"
            options:
              module: "pigeon_generator_example"
          kotlin: # Or true/false
            out: "android/app/src/main/kotlin/com/example/pigeon_generator_example"
            package: "com.example.pigeon_generator_example"
          java: # Or true/false
            out: "android/app/src/main/java/com/example/pigeon_generator_example"
            options:
              package: "com.example.pigeon_generator_example"
              use_generated_annotation: true
          swift: # Or true/false
            out: "ios/Runner"
          objc: # Or true/false
            header_out: "macos/Runner"
            source_out: "macos/Runner"
            options:
              prefix: "PGN"
          ast: # Or true/false
            out: "output"
          copyright_header: "pigeons/copyright.txt" # Not required if copyright.txt is in the same directory as the pigeons
          one_language: false
          debug_generators: false
          base_path: "pigeon_generator_example"
          skip_outputs:
            defaults: [ios] # Do not generate output for ios for pigeons/defaults.dart
          out_template: "name.g.extension" # Default

additional_public_assets:
  - pigeons/**
```

To test for android, copy the file `build.example.gradle` to `android/app/build.gradle`.
