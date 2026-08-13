# QoLGuard Mobile

Flutter client for QoLGuard — early detection of quality-of-life decline in
long-term medication users.

> This application provides decision support only. It does not diagnose disease
> and does not replace a healthcare professional.

## Requirements

- Flutter 3.32+ / Dart 3.8+
- An Android emulator or a physical device
- The backend running — see [`../backend/README.md`](../backend/README.md)

## Run

```
flutter pub get
flutter run
```

Open this `mobile/` folder as the VS Code workspace root, so the Flutter and
Dart extensions find `pubspec.yaml`.

## Backend connection

`lib/core/config/env.dart` resolves the API base URL per platform. The Android
emulator runs behind its own NAT, so `localhost` there means the emulator
itself, not your development machine — `10.0.2.2` is the alias mapping to the
host loopback. Getting this wrong is the most common reason a first
Flutter/FastAPI integration appears to hang.

To point at a different host, such as a physical phone reaching your laptop
over Wi-Fi:

```
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

The backend must then be started with `--host 0.0.0.0` so it accepts
connections from outside the machine. The bundled **QoLGuard API** PyCharm run
configuration already does this.

## Structure

```
lib/
├── main.dart              Entry point, ProviderScope
├── app.dart               MaterialApp, theme
└── core/
    ├── config/            Environment and app-wide constants
    ├── theme/             Colours and Material theme
    └── widgets/           Shared widgets
```

Features are added under `lib/features/<name>/` as they are built, each split
into `data/` (API clients and DTOs), `domain/` (entities and repository
interfaces), and `presentation/` (Riverpod providers and screens).

## Platforms

Android and iOS are the delivery targets. **Web and Windows are also enabled**,
purely as a development convenience — `flutter run -d chrome` reloads in a
second or two, where an Android emulator takes far longer, which makes UI work
much faster. Nothing in the codebase is desktop- or web-specific.

```
flutter run -d chrome     # fastest loop for UI work
flutter run -d windows    # desktop window
flutter run               # Android emulator or connected device
```

`lib/core/config/env.dart` resolves the backend URL per platform, so all three
reach the API without configuration: web and Windows use `localhost`, Android
uses `10.0.2.2`.

macOS and Linux are not enabled, since neither can be built from Windows. To add
any platform back:

```
flutter create --platforms=linux,macos .
```

## Tests

```
flutter analyze
flutter test
```
