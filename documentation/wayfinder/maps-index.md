# Ansible Wayfinder Maps Index

All major feature areas of Ansible are charted as Wayfinder Maps on GitHub Issues (`snackpackgames/ansible`) with destination type **`afk-implementation`**.

> **Note on GitHub labels & native sub-issues/dependencies:** Because the cloud GitHub App token restricts label creation and sub-issue/dependency API calls, run `bash scripts/wire_wayfinder_github.sh` once locally with your personal `gh` login to apply all `wayfinder:*` labels, native sub-issue links, and `blocked_by` edges.

## [Map: Core Architecture, Nakama + Rust WASM Backend & Web/Mobile Pipeline](https://github.com/snackpackgames/ansible/issues/1) (`#1`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Research] Nakama Go + Rust WASM (wazero/extism) runtime ABI and dev workflow](https://github.com/snackpackgames/ansible/issues/2) (`#2`) | `wayfinder:research` | **Frontier (unblocked)** *(report merged on `brebory/ansible#1`; pending upstream close)* |
| [[Research] Godot 4 Compatibility renderer WebGL2 export & nakama-godot WebSocket auth on browser and mobile](https://github.com/snackpackgames/ansible/issues/3) (`#3`) | `wayfinder:research` | **Resolved** ([0003 resolution](resolutions/0003-godot4-webgl2-nakama-websocket-auth.md)) |
| [[Grilling] Authoritative vs. optimistic client-server boundaries for offline-tolerant mobile play](https://github.com/snackpackgames/ansible/issues/4) (`#4`) | `wayfinder:grilling` | Blocked by [#2](https://github.com/snackpackgames/ansible/issues/2) *(unblocked once `#2` syncs; `#3` resolved)* |
| [[Task] Establish automated test suite (Rust cargo test, Godot GUT) and godot-mcp-runtime + ffmpeg playtest capture workflow](https://github.com/snackpackgames/ansible/issues/5) (`#5`) | `wayfinder:task` | **Frontier (unblocked)** |

## [Map: Turn-Based Squad Combat System (PS1-Era Cinematic Line-Up)](https://github.com/snackpackgames/ansible/issues/6) (`#6`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Grilling] Combat turn order model, action economy, and squad size](https://github.com/snackpackgames/ansible/issues/7) (`#7`) | `wayfinder:grilling` | **Resolved** ([0007 resolution](resolutions/0007-combat-turn-order-action-economy-squad-size.md)) |
| [[Grilling] Drifter battle classes, skill kits, and status/trigger taxonomy](https://github.com/snackpackgames/ansible/issues/8) (`#8`) | `wayfinder:grilling` | **Frontier (unblocked)** |
| [[Prototype] PS1-era Final Fantasy cinematic battle camera choreography](https://github.com/snackpackgames/ansible/issues/9) (`#9`) | `wayfinder:prototype` | **Frontier (unblocked)** |
| [[Grilling] Enemy factions, AI intent policies, retreat, and battle reward rules](https://github.com/snackpackgames/ansible/issues/10) (`#10`) | `wayfinder:grilling` | Blocked by [#8](https://github.com/snackpackgames/ansible/issues/8) |

## [Map: Drifters, Roster & Low-Poly 3D Recolorable Character Pipeline](https://github.com/snackpackgames/ansible/issues/11) (`#11`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Grilling] Drifter species (human & alien), base stats, traits, and vagrant arrival rules](https://github.com/snackpackgames/ansible/issues/12) (`#12`) | `wayfinder:grilling` | **Frontier (unblocked)** |
| [[Grilling] Multi-role drifter assignment (Builder, Researcher, Defender, Battle Class)](https://github.com/snackpackgames/ansible/issues/13) (`#13`) | `wayfinder:grilling` | Blocked by [#12](https://github.com/snackpackgames/ansible/issues/12) |
| [[Prototype] Low-poly 3D character rig and palette-mask recolorable shader for WebGL2](https://github.com/snackpackgames/ansible/issues/14) (`#14`) | `wayfinder:prototype` | **Frontier (unblocked)** |
| [[Grilling] Modular futuristic cowboy/drifter wardrobe & silhouette readability](https://github.com/snackpackgames/ansible/issues/15) (`#15`) | `wayfinder:grilling` | Blocked by [#14](https://github.com/snackpackgames/ansible/issues/14) |

## [Map: Roguelike Expeditions, Fog-of-War Star Map, Ships & Narrative Scenes](https://github.com/snackpackgames/ansible/issues/16) (`#16`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Grilling] Expedition run lifecycle, fog-of-war reveal rules, and risk-reward extraction](https://github.com/snackpackgames/ansible/issues/17) (`#17`) | `wayfinder:grilling` | **Frontier (unblocked)** |
| [[Grilling] Ship classes, construction/collection, and POI capability gating](https://github.com/snackpackgames/ansible/issues/18) (`#18`) | `wayfinder:grilling` | Blocked by [#17](https://github.com/snackpackgames/ansible/issues/17) |
| [[Grilling] Narrative scene structure, drifter stat/role checks, and combat handoffs](https://github.com/snackpackgames/ansible/issues/19) (`#19`) | `wayfinder:grilling` | Blocked by [#17](https://github.com/snackpackgames/ansible/issues/17) |
| [[Prototype] Touch-friendly fog-of-war star map & path-plotting UI](https://github.com/snackpackgames/ansible/issues/20) (`#20`) | `wayfinder:prototype` | Blocked by [#18](https://github.com/snackpackgames/ansible/issues/18) |

## [Map: Ansible Outpost Base Building, Research & Passage of Time](https://github.com/snackpackgames/ansible/issues/21) (`#21`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Grilling] Passage-of-time model: how expedition steps advance the Ansible outpost](https://github.com/snackpackgames/ansible/issues/22) (`#22`) | `wayfinder:grilling` | **Frontier (unblocked)** |
| [[Grilling] Outpost buildings, resource economy, and exploration scaling levers](https://github.com/snackpackgames/ansible/issues/23) (`#23`) | `wayfinder:grilling` | Blocked by [#22](https://github.com/snackpackgames/ansible/issues/22) |
| [[Grilling] Research tech tree & researcher drifter staffing mechanics](https://github.com/snackpackgames/ansible/issues/24) (`#24`) | `wayfinder:grilling` | Blocked by [#23](https://github.com/snackpackgames/ansible/issues/23) |
| [[Grilling] Outpost defense threats and garrisoned defender drifters](https://github.com/snackpackgames/ansible/issues/25) (`#25`) | `wayfinder:grilling` | Blocked by [#22](https://github.com/snackpackgames/ansible/issues/22), [#23](https://github.com/snackpackgames/ansible/issues/23) |

## [Map: Asynchronous Co-op Multiplayer & Shared Drifter Squads](https://github.com/snackpackgames/ansible/issues/26) (`#26`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Grilling] Shared Drifter Squad contract: publishing, borrowing, and expedition usage](https://github.com/snackpackgames/ansible/issues/27) (`#27`) | `wayfinder:grilling` | **Frontier (unblocked)** |
| [[Grilling] Cooperation resource rewards, daily cap reset rules, and anti-abuse constraints](https://github.com/snackpackgames/ansible/issues/28) (`#28`) | `wayfinder:grilling` | Blocked by [#27](https://github.com/snackpackgames/ansible/issues/27) |
| [[Research] Nakama Storage, Friends/Groups, and RPC design for async squad discovery and daily caps](https://github.com/snackpackgames/ansible/issues/29) (`#29`) | `wayfinder:research` | Blocked by [#28](https://github.com/snackpackgames/ansible/issues/28) |

## [Map: Neon Spaghetti Western UI & Visual/Audio Design System](https://github.com/snackpackgames/ansible/issues/30) (`#30`)

| Ticket | Type | Frontier / Dependencies |
| :--- | :--- | :--- |
| [[Prototype] Neon Spaghetti Western UI theme, holographic saloon/wanted panels & glow shaders](https://github.com/snackpackgames/ansible/issues/31) (`#31`) | `wayfinder:prototype` | **Frontier (unblocked)** |
| [[Grilling] Mobile & browser responsive layout and touch ergonomics across all game screens](https://github.com/snackpackgames/ansible/issues/32) (`#32`) | `wayfinder:grilling` | Blocked by [#31](https://github.com/snackpackgames/ansible/issues/31) |
| [[Grilling] Synth-spaghetti western audio direction, combat juice, and WebAudio constraints](https://github.com/snackpackgames/ansible/issues/33) (`#33`) | `wayfinder:grilling` | **Frontier (unblocked)** |
