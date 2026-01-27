<div align="center">

<img alt="Chain Reaction Reborn Logo" src="assets/logo-dark.png" width="128" height="128">

<br>

**A polished, modern reimplementation of the classic atomic strategy game.**

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter&style=for-the-badge)](https://flutter.dev) [![Release](https://img.shields.io/github/v/release/saatvik333/chain-reaction-reborn?style=for-the-badge)](https://github.com/saatvik333/chain-reaction-reborn/releases) [![License](https://img.shields.io/badge/License-GPLv3-green?style=for-the-badge)](LICENSE) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-ea4aaa?style=for-the-badge&logo=github)](https://github.com/sponsors/saatvik333)

</div>

---

## Overview

**Chain Reaction Reborn** brings the addictive gameplay of the classic strategy board game to modern devices with a complete visual overhaul. Strategic placement, explosive reactions, and tactical dominance await.

Compete against friends or challenge the smart AI in a battle for board control.

![Chain Reaction Reborn Showcase](assets/images/showcase.png)

## Features

- **Strategic Depth**: Classic atomic chain reaction mechanics that are easy to learn but hard to master.
- **Smart AI Opponents**:
  - **Easy**: Perfect for beginners.
  - **Medium**: A balanced challenge.
  - **Hard**: Uses heuristic evaluation.
  - **Extreme**: Minimax algorithm with Alpha-Beta pruning for tactical supremacy.
- **Local Multiplayer**: Support for up to **8 players** on a single device.
- **Visual Fidelity**:
  - Supports native refresh-rate for smooth animations.
  - Breathing atoms and dynamic particle explosions.
  - Haptic feedback integration.
- **Customization**:
  - **Theming System**: Unlockable themes (Earthy, Pastel, Amoled, etc.).
  - **Player Colors**: Customizable player identifiers.
- **Cross-Platform**:
  - **Mobile**: Optimized for Android and iOS.
  - **Desktop**: Full support for Windows, Linux, and macOS with native keybindings (F11 - Fullscreen, Esc - Back).

## Technology Stack

Built with a commitment to clean architecture and modern Flutter practices:

- **Framework**: Flutter & Dart
- **State Management**: [Riverpod](https://riverpod.dev) (v3+ with Code Generation)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Architecture**: Feature-First Clean Architecture (Domain-Driven Design principles)
- **Code Generation**: [Freezed](https://pub.dev/packages/freezed) & [JSON Serializable](https://pub.dev/packages/json_serializable) for immutable data models.

For a deep dive into the code structure, check out the [Architecture Documentation](architecture.md).

## Getting Started

### Prerequisites

- Flutter SDK (3.10.x or higher)
- Dart SDK

### Installation

1. Clone the repository

```bash
git clone https://github.com/saatvik333/chain-reaction-reborn.git
cd chain-reaction-reborn
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
# For Mobile
flutter run

# For Desktop (Linux/Windows/macOS)
flutter run -d linux # or windows/macos
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Linux AppImage/Bundle
flutter build linux --release
```

## Project Structure

```text
lib/
├── core/            # Shared utilities, constants, themes, and UI widgets
├── features/        # Feature modules
│   ├── game/        # Game engine, AI logic, and board rendering
│   ├── home/        # Main menu and setup wizard
│   ├── settings/    # User preferences (Theme, Audio)
│   └── shop/        # In-game store and content management
├── routing/         # Application navigation configuration
└── l10n/            # Localization files
```

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.