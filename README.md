# godot-ios-simulator-arm64

Prebuilt **arm64 iOS Simulator** libraries for Godot's iOS export template, so an Apple Silicon Mac can run Godot iOS builds in the Simulator without Rosetta.

## The problem

In the official Godot **4.7.2** iOS export template, the simulator slice of `libgodot` (and `libgodot_camera`) is `x86_64` only, even though the folder is named `ios-arm64_x86_64-simulator`. On an Apple Silicon Mac:

- an `arm64` simulator build fails to link (`_main` undefined);
- an `x86_64` build links but the Simulator refuses to install it (needs Rosetta, and newer simulator runtimes may refuse anyway).

This was checked with `lipo -info` on the template shipped with 4.7.2-stable.

## What this repo has

| File | What it is |
|---|---|
| `dist/libgodot.ios.template_debug.arm64.simulator.a` | Godot 4.7.2-stable, `platform=ios target=template_debug arch=arm64 simulator=yes` |
| `dist/libgodot_camera.ios.template_debug.arm64.simulator.a` | same, camera module |
| `dist/ios.zip` | the official 4.7.2 `ios.zip` with the two libraries merged into the simulator slice (`x86_64 arm64`) |
| `install.sh` | merges the `.a` files into your own installed `ios.zip` (keeps a `.orig` backup) |
| `build.sh` | rebuilds the `.a` files from the Godot source |
| `dist/SHA256SUMS` | checksums |

The binaries are in the **Releases** page, not in git (the main library is ~190 MB, over GitHub's 100 MB file limit).

## Use

1. Download the files from the latest Release into `dist/`.
2. Run `./install.sh` (patches the newest `ios.zip` under `~/Library/Application Support/Godot/export_templates/`), or copy the release `ios.zip` over yours if your template is exactly 4.7.2-stable.
3. In Godot, export the iOS project as usual, then build it for the simulator:

```sh
xcodebuild -project <Name>.xcodeproj -scheme <Name> -sdk iphonesimulator \
  -configuration Debug -arch arm64 -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/<Name>.app
xcrun simctl launch booted <bundle id>
```

## What was and was not tested

- **Tested (measured):** a project with one 3D box exported from Godot 4.7.2 (Mobile renderer), built with Xcode 27.2 for `arm64`, installed and launched on an iPhone 17 Pro simulator (iOS 27.2); the box rendered and the process stayed alive for 6 s. `install.sh` was run against a copy of the official `ios.zip` and both libraries came out as `x86_64 arm64`.
- **Not tested:** touch input, iPad, other Godot versions, other simulator runtimes, and any real-device build.
- **Debug template only.** The release (`template_release`) simulator slice is untouched, so release-mode simulator builds still need a separate build (`build.sh` with `target=template_release` edited in).
- Performance in the Simulator says nothing about real-device performance.

## Build it yourself

```sh
./build.sh 4.7.2-stable   # needs Xcode, git, python3; took about 3 minutes on an Apple Silicon Mac
```

## License

Godot is MIT licensed. `LICENSE` and `COPYRIGHT.txt` are copied unchanged from the Godot 4.7.2-stable source and apply to the binaries (they statically include Godot's third-party libraries). This repo is not affiliated with the Godot Engine.
