# Resolution: [Grilling] Combat turn order model, action economy, and squad size (#7)

- **Parent Map:** [Map: Turn-Based Squad Combat System (PS1-Era Cinematic Line-Up)](https://github.com/snackpackgames/ansible/issues/6) (`#6`)
- **Ticket:** [[Grilling] Combat turn order model, action economy, and squad size](https://github.com/snackpackgames/ansible/issues/7) (`#7`)
- **Resolved:** 2026-11-21

## Locked Decisions

1. **Turn Order Model — Dynamic CTB Action-Value Timeline (FFX style):**
   - Every living combatant tracks an integer **Action Value (AV)** seeded from `base_av = 10000 / speed` (deterministic integer math in Rust `sim-core`).
   - Lowest AV acts next, subtracting that AV from all other living combatants.
   - **Variable per-skill recovery weights (`recovery_pct`):** Skills carry an integer recovery multiplier (e.g., `75%` quick / `100%` standard / `125%` heavy) applied to `base_av` when resetting after acting, paired with a **live turn-strip preview** in the HUD when hovering or selecting skills.
   - **Deterministic CTB Tie-Breaker:** When two combatants hit `AV == 0` simultaneously → higher `speed` wins → `Player` faction before `Enemy` → lower `slot_index` wins.

2. **Action Economy — Shared Squad Cylinder AP + Enemy Cooldowns:**
   - **Player Squad:** Shares a 5-chamber holographic **Cylinder AP** pool (starts at `3`, max `5`). Basic actions and Guard generate `+1 Cylinder AP`; signature skills spend `1–2 Cylinder AP`.
   - **Enemies:** Use **per-enemy skill cooldowns / intent cycles** rather than a shared enemy AP pool, keeping enemy intents telegraphable and preventing minion deaths from funneling extra AP to surviving bosses.

3. **Formation & Squad Size:**
   - **Player Line-Up:** **3 core Drifters + optional 4th borrowed guest slot (3+1)** — preserves classic FF7/FF8 3-character framing while giving async co-op Shared Squad borrows a dedicated guest slot without benching the player's own crew.
   - **Enemy Line-Up:** **1–8 enemies** — supports classic PlayStation-era multi-enemy packs/swarms as well as compact elite/boss formations.

4. **Turn Pipeline & Reactive Triggers in Rust `sim-core`:**
   - Retains the canonical 7-stage **Turn Pipeline**: `Upkeep → PreExecValidation → PreExecTriggers → ExecuteAction → PostExecValidation → PostExecTriggers → EndTurn`.
   - **Reactive Triggers:** Resolved via a **bounded FIFO trigger queue (max depth 2)** inside the same single `battle_step` RPC call, emitting an ordered flat `BattleEvent` stream (`TriggerFired → CameraCue → DamageDealt → CombatantDefeated`) for deterministic Nakama WASM validation and sequential Godot playback without infinite counter loops.
   - **Death during `Upkeep` (e.g., Burn tick):** Combatant is immediately marked defeated, skips `PickAction`/`ExecuteAction`, executes `PostExecValidation` defeat/outcome checks, and advances the CTB clock without spending Cylinder AP.

## Domain Model & Downstream Impact

- **Updated [GLOSSARY.md](../../../GLOSSARY.md):** Added canonical terms **Action Value (AV)** and **Cylinder AP**, and updated **Squad** to `3 core Drifters + optional 4th borrowed guest slot (3+1)`.
- **New Fog Added to Map #6 (`Not yet specified`):** Staggered multi-row arena staging and touch target-selection ergonomics for large `5–8` enemy swarms on mobile screens.
- **Unblocked Frontier Tickets:**
  - [[Grilling] Drifter battle classes, skill kits, and status/trigger taxonomy](https://github.com/snackpackgames/ansible/issues/8) (`#8`)
  - [[Prototype] PS1-era Final Fantasy cinematic battle camera choreography](https://github.com/snackpackgames/ansible/issues/9) (`#9`)
