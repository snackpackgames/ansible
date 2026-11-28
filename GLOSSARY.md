# Ansible — Domain Context & Ubiquitous Language

> Canonical glossary for `snackpackgames/ansible`. Issues, plans, code symbols, and tests must use these terms consistently.

## Core Domain Terms

| Term | Definition | Avoid Synonyms |
| :--- | :--- | :--- |
| **Ansible** | The player's lonely frontier space outpost at the edge of uncharted space. Houses structures, research labs, defenses, and a roster of drifters. Advances as time passes during expeditions. | base, fortress, town (as primary noun) |
| **Drifter** | A recruitable human or alien vagrant who arrives at the Ansible. Has species, base stats (`grit`, `aim`, `tech`, `speed`), traits, a recolorable futuristic-western visual kit, and can be assigned to outpost roles or expedition battle classes. | hero, unit, colonist, pawn |
| **Role** | A Drifter's functional assignment — either an outpost duty (`Builder`, `Researcher`, `Defender`) or an expedition **Battle Class** (`Gunslinger`, `Vanguard`, `TechShaman`). | job, profession |
| **Squad** | A combat-ready formation of 3 core Drifters plus an optional 4th borrowed guest Drifter slot (3+1) deployed on an Expedition. | party, team |
| **Action Value (AV)** | A combatant's countdown timer on the dynamic CTB turn queue (`base_av = 10000 / speed`); the lowest AV acts next, then resets using `speed` and the executed skill's recovery weight (`recovery_pct`). | initiative roll, ATB bar |
| **Cylinder AP** | The Squad's shared 5-chamber holographic action pool (starts at 3 per battle); basic actions and Guard generate `+1`, while signature skills spend `1–2`. | mana, energy, MP |
| **Expedition** | A roguelike run departing from the Ansible into uncharted space. Players plot routes across a fog-of-war Star Map, resolve Narrative Scenes and Turn-Based Battles, and extract resources back to the Ansible. | dungeon, mission, raid |
| **Star Map** | The fog-of-war node graph of Points of Interest (POIs) explored during an Expedition. | world map, overworld |
| **POI (Point of Interest)** | A selectable node on the Star Map (e.g., Derelict Saloon, Scrap Nebula, Bandit Relay, Ancient Beacon). Access and visibility are gated by Ship capabilities and Ansible upgrades. | tile, encounter node |
| **Ship** | A collectible/buildable vessel assigned to an Expedition that determines Star Map jump range, scanner radius, cargo hold, and which specialized POIs can be selected. | vehicle, craft |
| **Shared Squad** | A snapshot of a player's Drifter Squad published to Nakama so friends or fellow frontier players can borrow it on Expeditions, awarding cooperation resources to the lender up to a server-enforced daily cap. | mercs, support team, clan loan |
| **Turn Pipeline** | The deterministic combat resolution sequence inherited from `ansible-text-specifications`: `Upkeep → PreExecValidation → PreExecTriggers → ExecuteAction → PostExecValidation → PostExecTriggers → EndTurn`. | combat loop |
| **Sim Core** | The deterministic Rust crate (`sim-core/`) compiled to `wasm32-unknown-unknown` and executed by the Nakama Go runtime (`wazero`) as the single source of truth for authoritative gameplay rules. | engine logic, backend rules |
