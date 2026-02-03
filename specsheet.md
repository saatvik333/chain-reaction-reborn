# Refactoring Implementation Task List  
Objective: Move the project from “great” to “best-in-class” through systematic, enforceable improvements.

---

## Phase 0 — Quality Baseline & Tooling

- [ ] Add `very_good_analysis: ^10.0.0` to `analysis_options.yaml`
- [ ] Remove all existing lint suppressions (`ignore`, `ignore_for_file`)
- [ ] Enable analysis as a hard CI gate
- [ ] Run analyzer and export full violation list
- [ ] Categorize violations:
  - Type safety
  - Architecture
  - Async correctness
  - Style / maintainability
- [ ] Freeze new feature development until baseline is clean

---

## Phase 1 — Fix Critical Analyzer Issues (Blockers)

### Async & correctness
- [ ] Replace all `async void` with `Future<void>`
- [ ] Await all futures or explicitly mark as fire-and-forget
- [ ] Remove `unawaited` without justification
- [ ] Eliminate `catch (e)` without `on` clauses
- [ ] Remove `throw` inside `finally`

### Type safety
- [ ] Eliminate all `dynamic`
- [ ] Replace `Object?` with concrete types
- [ ] Remove unchecked null assertions (`!`)
- [ ] Replace positional boolean parameters with named parameters
- [ ] Declare all return types explicitly

---

## Phase 2 — Domain Modeling Hardening

- [ ] Identify all core domain concepts
- [ ] Replace primitive types with value objects where applicable:
  - IDs
  - Status values
  - Monetary values
  - Timestamps
- [ ] Convert nullable state fields into explicit Freezed unions
- [ ] Ensure invalid domain states are unrepresentable
- [ ] Remove defensive runtime checks replaced by types

---

## Phase 3 — Architectural Boundary Cleanup

- [ ] Audit all imports for layer violations
- [ ] Remove Flutter imports from domain layer
- [ ] Enforce Presentation → Domain → Data dependency direction
- [ ] Move side effects behind interfaces
- [ ] Remove shared `utils` dumping grounds
- [ ] Relocate logic into feature-local or domain services
- [ ] Ensure repositories are interface-driven

---

## Phase 4 — State & Flow Determinism

- [ ] Convert complex Riverpod providers into explicit controllers/notifiers
- [ ] Model provider states as sealed unions
- [ ] Make all state transitions explicit
- [ ] Separate:
  - Commands (actions)
  - State derivation (pure logic)
- [ ] Remove hidden side effects inside providers
- [ ] Ensure single-entry, single-exit async flows

---

## Phase 5 — Error & Failure Modeling

- [ ] Inventory all thrown exceptions
- [ ] Replace generic exceptions with domain-specific failure types
- [ ] Model failures as Freezed unions
- [ ] Ensure all async boundaries return typed results
- [ ] Map infrastructure errors at repository boundaries only
- [ ] Ensure UI can render every failure state

---

## Phase 6 — very_good_analysis Cleanup (Maintainability)

- [ ] Remove unused parameters
- [ ] Remove empty blocks
- [ ] Replace verbose functions with expression bodies where appropriate
- [ ] Prefer const constructors and literals
- [ ] Remove redundant argument values
- [ ] Fix unnecessary container/widget nesting
- [ ] Eliminate dead code paths

---

## Phase 7 — Test Realignment

- [ ] Audit existing tests for brittleness
- [ ] Rewrite tests to assert behavior, not implementation
- [ ] Add unit tests for:
  - Domain rules
  - State transitions
- [ ] Add widget tests only for meaningful UI behavior
- [ ] Add regression test for every known bug
- [ ] Remove redundant or low-signal tests

---

## Phase 8 — Performance Discipline

- [ ] Audit widget rebuild frequency
- [ ] Identify allocation-heavy hot paths
- [ ] Remove synchronous IO from UI thread
- [ ] Introduce explicit caching strategies
- [ ] Set performance budgets per critical flow
- [ ] Verify no unnecessary rebuilds via provider misuse

---

## Phase 9 — Security & Privacy Tasks

- [ ] Centralize all secure storage access
- [ ] Remove secrets from non-secure storage
- [ ] Shorten credential/token lifetimes
- [ ] Scrub logs of sensitive data
- [ ] Remove `print` and debug logging
- [ ] Enforce least-privilege access patterns

---

## Phase 10 — Deletion & Simplification Pass

- [ ] Delete unused features and flows
- [ ] Remove abstractions without clear value
- [ ] Inline over-generalized layers
- [ ] Replace comments with expressive types
- [ ] Rename symbols to encode intent

---

## Phase 11 — Enforcement & Maintenance

- [ ] Lock CI to fail on:
  - Analyzer warnings
  - Test failures
  - Stale generated code
- [ ] Require architectural review for boundary changes
- [ ] Schedule quarterly lint and dependency audits
- [ ] Treat refactoring as continuous work

---

## Completion Criteria

- [ ] Zero analyzer warnings
- [ ] No ignored lints
- [ ] Fully typed domain
- [ ] Enforced architectural boundaries
- [ ] Deterministic state flows
- [ ] Tests encode intent
- [ ] System remains stable under change
