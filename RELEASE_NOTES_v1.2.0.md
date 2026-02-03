# Release v1.2.0

## 🚀 Major Features & Refactors
- **Riverpod 3.x & Freezed**: Complete migration of state management to Riverpod 3.x (Notifier/AsyncNotifier) and data classes to Freezed for immutability and better developer experience.
- **Desktop Support**: Full desktop integration (Linux, macOS, Windows) with:
    - Responsive design improvements.
    - Window management.
    - Keyboard shortcuts and mouse hover effects.
- **Architecture Overhaul**: Enforced Clean Architecture principles with strict separation of Presentation, Domain, and Data layers.
- **In-App Purchases**: Integrated IAP with secure storage for verifying and persisting purchases.
- **Navigation**: Migrated to `go_router` for robust, declarative routing and deep linking support.

## ✨ UI/UX Enhancements
- **Fluid UI**: Implemented fluid dialogs and responsive layouts for varying screen sizes.
- **Visual Effects**: 
    - Configurable atom vibration and rotation effects.
    - Enhanced particle systems for chain reactions.
    - Custom painters for optimized rendering.
- **Localization**: Added support for localizing all user-facing strings.

## 🛠 Technical Improvements
- **Performance**: Optimized rendering pipeline and reduced unnecessary rebuilds.
- **Code Quality**: Applied `very_good_analysis` and strict linting rules.
- **Testing**: Refactored test suite to align with new architecture.

## 📦 Dependency Updates
- Updated `flutter_riverpod`, `freezed`, `go_router` to latest versions.
