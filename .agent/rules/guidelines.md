---
trigger: always_on
---

# Flutter Mobile Application Standards

## 1. Purpose
Define non-negotiable engineering, architectural, and operational requirements for production-grade Flutter mobile applications using a modern Riverpod-based stack. This document is normative.

---

## 2. Supported platforms
- Primary: Android, iOS
- Secondary (optional): desktop and web, only where abstractions already support them
- Platform-specific code must be isolated and replaceable

---

## 3. Architectural principles
- Enforce **clean, layered architecture**:
  - Presentation (UI, widgets, pages)
  - Domain (business rules, entities, use-cases)
  - Data (repositories, data sources, adapters)
- Dependencies flow inward only.
- UI contains no business logic.
- Domain layer must be pure Dart and platform-agnostic.
- All side effects (IO, storage, purchases, vibration, platform APIs) must be behind interfaces.

---

## 4. Project structure
```

lib/
src/
core/
errors/
utils/
di/
features/
<feature_name>/
presentation/
domain/
data/
models/
providers/

```
- No “utils dumping ground”.
- Feature boundaries are strict.
- Cross-feature access only through domain contracts.

---

## 5. State management (Riverpod)
- Riverpod is the **single source of truth** for application state.
- Use `Notifier` / `AsyncNotifier` patterns.
- Providers must be deterministic and side-effect aware.
- No mutable global state.
- UI listens; it never owns state.
- Provider lifetimes must be explicit and scoped.

---

## 6. Navigation (GoRouter)
- Routing is declarative and centralized.
- Deep linking must be supported.
- Route guards (auth, onboarding, entitlement) must depend on providers, not UI state.
- Navigation logic must be testable and context-independent.

---

## 7. Data modeling & immutability
- All models must be immutable.
- Use Freezed for:
  - Value equality
  - Copy semantics
  - Sealed unions
- No `dynamic` in domain or data layers.
- JSON parsing occurs only at data boundaries.
- Domain models must not depend on serialization annotations.

---

## 8. Code generation
- `build_runner` is mandatory for:
  - Freezed
  - JSON serialization
  - Riverpod generators
- Generated code must not be manually edited.
- CI must fail on stale generated files.

---

## 9. Persistence & storage
- `shared_preferences`
  - Non-sensitive flags only
  - Small data, low frequency access
- `flutter_secure_storage`
  - Tokens, credentials, secrets
  - Never used as a general database
- All storage access goes through abstractions.
- No direct plugin access in UI or domain layers.

---

## 10. Internationalization
- All user-facing strings must be localized.
- No hardcoded text in widgets.
- Locale changes must propagate dynamically.
- Date, number, and currency formatting must respect locale.

---

## 11. Platform integrations
- All platform features (purchases, vibration, display modes, window management) must:
  - Be capability-checked
  - Fail gracefully
  - Be abstracted behind interfaces
- No platform logic inside widgets.

---

## 12. Security requirements
- No secrets committed to source control.
- No plaintext credentials stored on device.
- Secure storage only for minimum required lifetime.
- Network communication must assume hostile environments.
- Logs must never contain secrets or personal data.
- Feature code must be written assuming device compromise.

---

## 13. Privacy requirements
- Data minimization by default.
- Explicit user consent where applicable.
- Clear separation between analytics, diagnostics, and core logic.
- Ability to disable non-essential telemetry.

---

## 14. Accessibility (mandatory)
- Semantic widgets required.
- Screen reader support verified.
- Minimum touch target sizes respected.
- Dynamic text scaling supported.
- Color contrast must meet accessibility thresholds.

---

## 15. Performance constraints
- No blocking work on the UI thread.
- Heavy computation must use isolates.
- List rendering must be lazy and paginated.
- Asset sizes must be controlled and audited.
- Startup time and frame stability are tracked metrics.

---

## 16. Error handling & resilience
- Centralized error mapping.
- User-facing errors must be actionable and human-readable.
- Retry strategies must be explicit.
- No silent failures.
- Crash reporting is mandatory in production.

---

## 17. Testing requirements
- Mandatory test pyramid:
  - Unit tests: domain and providers
  - Widget tests: UI behavior
  - Integration tests: critical user flows
- Business logic must be testable without Flutter bindings.
- Mocks/fakes required for IO and platform code.
- CI must block on test failure.

---

## 18. Linting & code quality
- `flutter_lints` enforced.
- Zero analyzer warnings tolerated.
- Sound null-safety required.
- No unchecked null assertions without justification.
- Formatting enforced via automated tooling.

---

## 19. CI/CD requirements
- Automated pipeline must include:
  - Static analysis
  - All test suites
  - Release builds
  - Artifact signing
- Secrets managed only through CI secret stores.
- Manual release steps are prohibited.

---

## 20. Dependency management
- Dependencies must be actively maintained.
- Regular audits required.
- Transitive dependency risk must be reviewed.
- Codegen dependencies are treated as production-critical.

---

## 21. Release readiness checklist
- Tests passing
- Accessibility verified
- Security review completed
- Performance metrics within targets
- Localization complete
- Rollback strategy defined

---

## 22. Pull request requirements
- Scoped, minimal changes
- Tests included
- Lint clean
- Generated files updated
- Clear changelog entry

---

## 23. Enforcement
Deviation from this rulebook requires explicit architectural approval. Silence is not approval.
