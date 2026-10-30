# dart-math-equation-support

An MCQ practice app that renders mathematical equations properly.

## Highlights

- **`flutter_math_fork`** — renders LaTeX-style equations inline.
- Questions fetched over the network with `dio` and a bearer token.
- Loading, error and empty states handled explicitly.
- HTML entities decoded with `html_unescape` for clean question text.

## Tech Stack

| Concern | Choice |
|---|---|
| UI | Flutter, Material |
| Networking | `dio` |
| Math rendering | `flutter_math_fork` |
| Utilities | `html_unescape` |

## Project Structure

```
lib/
- `main.dart`
```

## Getting Started

### Prerequisites

- Flutter `>= 3.16` (Dart `>= 3.2`)

### Run

```bash
git clone https://github.com/developer-rahim/dart-math-equation-support.git
cd dart-math-equation-support
flutter pub get
flutter run
```

### Test

```bash
flutter test
flutter analyze
```

## Notes

The API base URL and token live in `lib/main.dart`. Move the token to `--dart-define` before sharing this repo — see the security note in the root PROFILE.md.

## License

Released under the MIT License.
