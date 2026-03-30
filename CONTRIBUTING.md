# Contributing to AuraNoise

Thank you for your interest in contributing to AuraNoise! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and constructive in all interactions
- Focus on what is best for the project and the community
- Welcome newcomers and help them get started

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with the following information:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Step-by-step instructions to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Platform**: Android, Linux, Windows, Web, etc.
- **Flutter Version**: Output of `flutter doctor`
- **Screenshots**: If applicable

### Suggesting Features

Feature suggestions are welcome! Please open an issue with:

- **Feature Description**: Clear explanation of the proposed feature
- **Use Case**: Why would this feature be useful?
- **Implementation Ideas**: Optional suggestions on how to implement

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/auranoise.git
   cd auranoise
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if needed

4. **Test Your Changes**
   ```bash
   flutter analyze
   flutter test
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

   Commit message format:
   - `feat: description` - New feature
   - `fix: description` - Bug fix
   - `docs: description` - Documentation changes
   - `refactor: description` - Code refactoring
   - `test: description` - Test changes
   - `chore: description` - Maintenance tasks

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4
- Android SDK (for Android builds)
- CMake (for Linux builds)
- Visual Studio (for Windows builds)

**Linux Additional Requirements:**
```bash
# Ubuntu/Debian
sudo apt-get install mpv libmpv-dev

# Fedora
sudo dnf install mpv mpv-devel
```

### Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d linux
flutter run -d android
flutter run -d chrome
```

## Code Style

### Dart/Flutter Style

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter_lints` rules (configured in `analysis_options.yaml`)
- Run `flutter analyze` before committing
- Run `flutter dart fix` to auto-fix lint issues

### File Organization

```
lib/
├── models/          # Data models
├── services/        # Business logic
├── screens/         # Full-screen widgets
└── widgets/         # Reusable components
```

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE` for top-level

## Adding New Sounds

If you want to add a new built-in sound:

1. **Audio File**
   - Format: OGG (Vorbis codec)
   - Quality: 128-192 kbps
   - Duration: 10-30 seconds (seamless loop preferred)
   - Location: `assets/sounds/your-sound.ogg`

2. **Icon**
   - Format: SVG
   - Size: 24x24px viewBox
   - Style: Simple, single color
   - Location: `assets/icons/your-sound.svg`

3. **Registration**
   - Add to `lib/models/sound_groups.dart`
   - Add to `pubspec.yaml` assets section

4. **Attribution**
   - Ensure you have rights to use the audio
   - Add attribution in README if required

## Testing

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

- Add widget tests for UI components
- Add unit tests for service logic
- Test edge cases (empty states, errors)

## Documentation

- Update README.md if adding features
- Update CLAUDE.md with implementation details
- Add inline comments for complex logic
- Update CHANGELOG.md

## Questions?

Feel free to open an issue for:
- Questions about the codebase
- Help getting started
- Discussion about features

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to AuraNoise! 🎵
