# Chain Reaction Reborn - Technical Architecture

This document provides a deep technical dive into the **Chain Reaction Reborn** project. It covers the architectural patterns, state management strategy, core game algorithms, and component interactions using Mermaid diagrams.

## 1. High-Level Architecture
The project follows a **Feature-First Clean Architecture**. Code is organized primarily by *feature* (vertical slices) and then by *layer* (horizontal slices).

### Architectural Layers
- **Presentation**: UI widgets, screens, and Riverpod Notifiers (State Management). Uses **GoRouter** for declarative navigation.
- **Domain**: Pure Dart business logic, **Freezed** Entities (Immutable), Use Cases, and Repository Interfaces.
- **Data**: Implementation of Repositories, Data Sources (SharedPreferences), and DTOs.

```mermaid
flowchart TD
    subgraph Presentation["Presentation Layer"]
        UI[Flutter Widgets] --> Router[GoRouter]
        UI --> Notifiers[Riverpod Notifiers]
    end

    subgraph Domain["Domain Layer"]
        Notifiers --> UseCases[Use Cases]
        UseCases --> Entities["Entities<br/>(Freezed Immutable)"]
        UseCases --> RepoInterface[Repository Interfaces]
    end

    subgraph Data["Data Layer"]
        RepoInterface -.-> RepoImpl[Repository Implementation]
        RepoImpl --> LocalStorage[SharedPreferences]
    end

    style Presentation fill:#f9f9f9,stroke:#333,stroke-width:1px
    style Domain fill:#e3f2fd,stroke:#1565c0,stroke-width:1px
    style Data fill:#fff3e0,stroke:#ef6c00,stroke-width:1px
```

## 2. Directory Structure
The codebase uses a standard scalable folder structure:

```text
lib/
├── core/                  # Shared utilities
│   ├── routing/           # GoRouter configuration
│   ├── theme/             # App Theme & Palettes
│   └── utils/             # JsonConverters, Constants
├── l10n/                  # Localization (Arb files, Generated Code)
├── features/
│   ├── game/              # CORE FEATURE: Game Board, Logic, AI
│   ├── home/              # Entry point wizard (Mode Selection)
│   ├── settings/          # User Preferences
│   └── shop/              # Theme Marketplace
├── widgets/               # Reusable UI components (Buttons, Dialogs)
└── main.dart              # App bootstrapping
```

## 3. Core Game Logic
The heart of the application is the `features/game` module. It handles the turn-based logic, recursion, and animations.

### The Chain Reaction Algorithm
The game relies on a recursive propagation logic when a cell reaches critical mass. Domain entities (`Cell`, `GameState`, `Player`, `FlyingAtom`) are **immutable** and generated using `freezed`.

```mermaid
sequenceDiagram
    autonumber
    participant User
    participant UI as GameNotifier
    participant Logic as PlaceAtomUseCase
    participant Rules as GameRules
    participant State as GameState

    User->>UI: Tap Cell (x,y)
    UI->>Logic: execute(state, x, y)
    Logic->>State: Check atom count

    alt Stable Placement
        Logic->>State: Increment Count (copyWith)
        Logic-->>UI: Yield New State
    else Critical Mass (Explosion)
        loop Recreational Expansion
            Logic->>Rules: Get Neighbors
            Logic->>State: Reset Cell & Create Projectiles
            Logic-->>UI: Yield State (Animating)
            Note right of UI: UI renders flying atoms

            UI->>UI: Await 250ms (Animation)

            Logic->>State: Land Atoms on Neighbors
            Logic-->>UI: Yield State (Landed)
        end
    end
```

### AI Engine
The AI uses a **Strategy Pattern** to support multiple difficulty levels.

```mermaid
classDiagram
    direction TB
    class AIService {
        +getMove(GameState) Future~Point~
    }
    class AIStrategy {
        <<interface>>
        +computeMove(GameState) Point
    }
    class RandomStrategy
    class GreedyStrategy
    class MinimaxStrategy

    AIService --> AIStrategy : Uses
    AIStrategy <|.. RandomStrategy
    AIStrategy <|.. GreedyStrategy
    AIStrategy <|.. MinimaxStrategy
```
- **Random**: Picks any valid cell.
- **Greedy**: Prioritizes moves that capture the most cells immediately.
- **Minimax**: A depth-limited search (Depth=2) that simulates user responses to minimize the opponent's maximum possible gain. It runs in a background **Isolate** to avoid freezing the UI.

## 4. State Management (Riverpod)
We use `NotifierProvider` for complex state and `Provider` for read-only values.

### Provider Graph used in `GameScreen`
```mermaid
flowchart TD
    Root[ProviderScope] --> Global
    Root --> GameScope

    subgraph Global["Global Scope"]
        Theme[themeProvider]
        Settings[settingsRepositoryProvider]
        Router[routerProvider]
    end

    subgraph GameScope["Game Session Scope"]
        Game[gameStateProvider]
        Game --> Players[currentPlayerProvider]
        Game --> Grid[gridProvider]
        Game --> Status[isGameOverProvider]
    end

    GameScreen --> Game
    GameScreen --> Router
    GameGrid --> Grid
    
    style Global fill:#f3e5f5,stroke:#7b1fa2
    style GameScope fill:#e0f2f1,stroke:#00695c
```

## 5. Navigation Flow
The app uses **Declarative Navigation** via `go_router`. All routes are defined in `AppRouter`.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Splash
    Splash --> Home

    state Home {
        [*] --> ModeSelection
        ModeSelection --> Configuration : Select
        Configuration --> ModeSelection : Back
    }

    Home --> GameScreen : Start Game
    
    state GameScreen {
        [*] --> Playing
        Playing --> Paused : Menu
        Paused --> Playing : Resume
        Playing --> GameOver : Win Condition
    }

    GameOver --> WinnerScreen : End
    WinnerScreen --> Home : Home
    WinnerScreen --> GameScreen : Replay
```

## 6. Rendering Pipeline
The game grid is too dense for standard Flutter widgets (`Container`, `Column`, `Row`) to animate efficiently at 60fps on low-end devices.

### Key Optimization: `CustomPainter`
Instead of widgets, atoms are drawn directly onto the canvas.
- **`AtomPainter`**: Handles drawing the circles, shadows, and rotation.
- **`GameGrid`**: Contains a single `AnimationController` that drives the "breathing" and "rotation" of *all* atoms simultaneously.

```dart
// Simplified Logic
void paint(Canvas canvas, Size size) {
    for (var atom in atoms) {
       // 1. Calc Rotation based on global animation value
       // 2. Calc 'Breathing' scale (Sine wave)
       // 3. Draw Circle
    }
}
```

## 7. Data Persistence
Persistence is handled by `shared_preferences` behind Repository interfaces.

| Feature | Data Stored | Key Example |
| :--- | :--- | :--- |
| **Settings** | Booleans, Strings | `isDarkMode`, `isSoundOn` |
| **Shop** | List of Strings | `purchased_themes` |
| **Game** | JSON Blob | `active_game_state` |

The `GameRepository` serializes the entire `GameState` object using `AppJsonConverters` and `freezed`'s `toJson` logic to support "Resume Game" functionality. A custom `ColorConverter` handles standardizing color values.

## 8. Internationalization (l10n)
The project supports multiple languages (currently English) using `flutter_localizations`.

### Workflow
1. **Source of Truth**: `lib/l10n/arb/app_en.arb` (JSON-like key-values).
2. **Generation**: `flutter gen-l10n` reads ARB files and generates Dart code in `lib/l10n/generated/`.
3. **Usage**: `AppLocalizations.of(context)!.keyName`.

### Key Components
- **`AppLocalizations`**: The generated class containing all localized strings.
- **`l10n.yaml`**: Configuration file defining input/output directories.
