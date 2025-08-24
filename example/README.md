Below is an example of a build.yaml file that can be used to generate pigeons.

```yaml
targets:
  $default:
    builders:
      pigeon_generator:
        options:
          inputs: pigeons # Default
          dart: # Or true/false
            out: "lib" # Default if not set or true
            test_out: "test" # Or true/false
            package_name: "pigeon_generator_example"
            options:
              source_out: "lib/src"
              test_out: "test/src"
              copyright_header: ["Copyright 2024"]
          objc: # Or true/false
            header_out: "macos/Runner"
            source_out: "macos/Runner"
            options:
              header_include: "macos/Runner"
              prefix: "PGN"
              copyright_header: ["Copyright 2024"]
          java: # Or true/false
            out: "android/app/src/main/java/com/example/pigeon_generator_example"
            options:
              package: "com.example.pigeon_generator_example"
              copyright_header: ["Copyright 2024"]
              use_generated_annotation: false
          swift: # Or true/false
            out: "ios/Runner"
            options:
              copyright_header: ["Copyright 2024"]
              include_error_class: true
          kotlin: # Or true/false
            out: "android/app/src/main/kotlin/com/example/pigeon_generator_example"
            options:
              package: "com.example.pigeon_generator_example"
              copyright_header: ["Copyright 2024"]
              include_error_class: true
          cpp: # Or true/false
            header_out: "windows/runner"
            source_out: "windows/runner"
            options:
              header_include: "windows/runner"
              namespace: "pigeon_generator_example"
              copyright_header: ["Copyright 2024"]
              header_out: "windows/runner"
          gobject: # Or true/false
            header_out: "linux"
            source_out: "linux"
            options:
              header_include: "linux"
              namespace: "pigeon_generator_example"
              copyright_header: ["Copyright 2024"]
              header_out: "linux"
          ast: # Or true/false
            out: "output"
          copyright_header: "pigeons/copyright.txt" # Not required if copyright.txt is in the same directory as the pigeons
          debug_generators: false
          base_path: "pigeon_generator_example"
          skip_outputs:
            defaults: [objc] # Options include: dart, dart_test, java, kotlin, swift, objc, cpp, gobject, ast
          out_folder: "pigeons"
          out_template: "name.g.extension" # Default

additional_public_assets:
  - pigeons/**
```

To test for android, copy the file `build.example.gradle` to `android/app/build.gradle`.
