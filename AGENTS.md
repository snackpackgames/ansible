# Ansible — Agent & Developer Guide

**Ansible** is a base-building space exploration RPG with a **neon spaghetti western** aesthetic: players manage a lonely frontier outpost (an Ansible), recruit human and alien Drifters across outpost and combat roles, embark on roguelike Expeditions across a fog-of-war Star Map while time passes at the base, fight PlayStation-era Final Fantasy cinematic turn-based line-up battles, and share Drifter Squads asynchronously with other players for daily-capped cooperative rewards.

---

## Architecture Overview

| Layer | Location | Tech Stack | Role |
| :--- | :--- | :--- | :--- |
| **Game Client** | `client/` | Godot 4 (Compatibility / WebGL2 renderer, GDScript) | Targets Web (single-threaded HTML5) + Mobile (iOS/Android) + Desktop; connects via WebSockets/HTTPS (`nakama-godot` compatible adapter) |
| **Simulation Core** | `sim-core/` | Rust (`wasm32-unknown-unknown` + native) | Deterministic turn-based combat pipeline (`Upkeep → Validate → Triggers → Execute → EndTurn`), enemy AI, and shared-squad daily-cap economy |
| **Backend Server** | `server/` | Nakama Go runtime plugin + `wazero` WASM host | Auth, WebSockets, Storage Engine, Friends/Groups, RPCs delegating game rules to `sim_core.wasm` |
| **Playtesting & Capture** | `.mcp.json`, `scripts/record_playtest.sh` | `godot-mcp-runtime` (`Erodenn/godot-mcp-runtime`) + `ffmpeg` | Live runtime scene inspection/input via MCP + deterministic MovieWriter / Xvfb `ffmpeg` video & screenshot capture |

Read [GLOSSARY.md](GLOSSARY.md) for canonical domain terms and [documentation/adr/0001-godot-nakama-rust-wasm-stack.md](documentation/adr/0001-godot-nakama-rust-wasm-stack.md) for stack rationale.

---

## Common Commands

```bash
# Run the full test suite (Rust unit tests + WASM build + Go wazero bridge tests + Godot headless battle tests)
bash scripts/test.sh

# Compile Rust simulation core to WebAssembly for Nakama Go runtime
bash scripts/build_wasm.sh

# Record automated playtest footage (MP4 + GIF + PNG keyframes) using Godot MovieWriter + ffmpeg
bash scripts/record_playtest.sh

# Record live interactive playtest session via Xvfb + x11grab (for use alongside godot-mcp-runtime)
bash scripts/record_playtest.sh --mode x11grab --duration 20

# Verify Godot + godot-mcp-runtime setup
bash scripts/setup_mcp.sh

# Boot local Nakama + PostgreSQL + Go/WASM server stack
docker compose up --build
```

---

## Wayfinder & Issue Pipeline

- All major feature areas are charted as Wayfinder Maps in GitHub Issues (`snackpackgames/ansible`) with destination type `afk-implementation`. See [documentation/wayfinder/maps-index.md](documentation/wayfinder/maps-index.md).
- To apply `wayfinder:*` labels, native GitHub sub-issue links, and native `blocked_by` edges from a local shell with full `gh` auth, run:
  ```bash
  bash scripts/wire_wayfinder_github.sh
  ```

## Playtesting with `godot-mcp-runtime`

1. Ensure `godot` (4.5+) and Node.js 20+ are on `PATH`.
2. `.mcp.json` registers `godot-runtime` (`npx -y godot-mcp-runtime`).
3. Use `run_project` on `client/`, inspect visible Neon Western HUD Controls via UI discovery, click skills/targets or trigger live GDScript, and capture screenshots or run `scripts/record_playtest.sh` to produce reviewable MP4/GIF footage.
4. Keep `.mcp/` ignored in git (auto-cleaned by `godot-mcp-runtime`).

## Worktree Policy

- Use sibling worktrees (`../ansible-<suffix>`) only. Never create nested worktrees inside the repository root (Godot recursively scans subdirectories).

## Agent skills

### Issue tracker

GitHub Issues (`snackpackgames/ansible`, via the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (`GLOSSARY.md` and `documentation/adr/`). See `docs/agents/domain.md`.
