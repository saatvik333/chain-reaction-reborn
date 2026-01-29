# Release v1.1.1

## 🚀 New Features
- **Undo System**: Added an undo button to the game screen, allowing players to revert moves (handles both PvP and AI turns).
- **Visual Enhancements**:
  - **Atom Animations**: Added organic "breathing" and vibration effects to atoms.
  - **Grid Polish**: Improved cell hover, splash, and highlight effects.
  - **Loading Indicators**: Refined UI loading states.
- **Assets**: Added padded versions of the application logos.

## 🤖 AI Improvements
- **Balancing**:
  - **Extreme Strategy**: Introduced a 22% "lapse" chance to make the hardest difficulty slightly more beatable (simulating human error).
  - **Strategic Strategy**: Adjusted difficulty factor from 0.85 to 0.75.
- **Logic Fixes**: Improved "critical mass" detection logic for Greedy and Strategic bots.

## 🛠 Improvements & Fixes
- **UI Constants**: Centralized dimensions and animation constants in `AppDimensions`.
- **Input**: Enabled sentence capitalization in the "Edit Player" dialog.
- **Web**: Updated `index.html` to include `flutter_bootstrap.js`.
