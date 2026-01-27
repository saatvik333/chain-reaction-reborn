# v1.1.0 - Visual Polish & Architectural Overhaul

This release represents a major milestone in the technical maturity of **Chain Reaction Reborn**, upgrading the core architecture to strictly follow modern Flutter best practices (Riverpod 3.x, Freezed, Clean Architecture). It also introduces monetization features and prepares the app for a wider audience with localization support.

## ✨ New Features

- **Shop & Monetization**
  - Integrated robust In-App Purchase (IAP) system.
  - Added secure storage and validation for purchased items (palettes/themes).
- **Localization**
  - Implemented foundation for multi-language support (l10n).
- **Visual & UI**
  - Added polished assets for Dark Mode.
  - Refined visual feedback and UI interactions.

## 🏗 Architectural Modernization

- **State Management (Riverpod 3.x + Freezed)**
  - Migrated `Home`, `Shop`, and `Game` engines to use the Generator package.
  - Converted all state models to `Freezed` unions for exhaustive pattern matching and immutability.
- **Routing**
  - Fully migrated navigation system to `go_router` for better deep linking and state-based routing.
- **Clean Architecture**
  - Restructured project into strict `Data`, `Domain`, and `Presentation` layers.
  - consolidated services and providers for better dependency injection.

## 🧹 Maintenance & Cleanup

- **Audio System**: Removed legacy audio implementation to simplify the core loop (will be reimagined in v1.2.0).
- **Codebase**: General cleanup of unused services and legacy provider patterns.

## 📦 Commits

- feat(app): release v1.1.0 with visual polish and dark mode assets
- refactor(state): migrate home, shop, and game engines to Riverpod 3.x and Freezed
- refactor(core): migrate to freezed using clean architecture entities and go_router
- feat(shop): integrate in-app purchases with secure storage and validation
- refactor(app): remove audio system and code cleanup
- refactor(app): consolidate services and restructure provider architecture
- feat(app): implement localization, persistence, and architectural improvements
