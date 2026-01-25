# Chain Reaction Reborn

A polished, modern reimplementation of the classic Chain Reaction strategy game, built with Flutter.

![Logo](lib/assets/logo.png)

## 🎮 Features

- **Strategic Gameplay**: Classic atomic chain reaction mechanics.
- **Smart AI**: Challenge yourself against 4 levels of Computer difficulty (Easy to Extreme).
- **Local Multiplayer**: Play with up to 8 friends on a single device.
- **Visuals**: Beautiful animations, particle effects, and "breathing" atoms.
- **Customization**: Uncleckable themes and color palettes.
- **Cross-Platform**: Optimized for Mobile and Desktop (Windows, Linux, macOS) with responsive design.

## 🛠️ Architecture

This project uses a **Feature-First Clean Architecture** with **Riverpod** for state management.
For a deep dive into the code structure, check out the [Architecture Documentation](architecture.md).

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.x or higher)
- Dart SDK

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/saatvik333/chain_reaction.git
    cd chain_reaction
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    # For Mobile
    flutter run

    # For Desktop (Linux/Windows/Mac)
    flutter run -d linux # or windows/macos
    ```

## 📂 Project Structure

- `lib/features/game`: Core logic, AI engine, and Game Board rendering.
- `lib/features/home`: Main Menu and Game Configuration wizard.
- `lib/features/settings`: User preferences (Dark Mode, Audio, etc.).
- `lib/features/shop`: Theme store and entitlement management.
- `lib/core`: Shared utilities and Design System definitions.

## 🤖 AI Implementation

The game features an AI opponent using a **Minimax Algorithm** with Alpha-Beta pruning (Extreme difficulty) and heuristic evaluation strategies (Hard difficulty) to provide a genuine challenge.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
