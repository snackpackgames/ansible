#!/usr/bin/env bash
# Sync locally recorded Wayfinder ticket resolutions to GitHub Issues on snackpackgames/ansible.
# Run once locally with full gh auth whenever cloud GitHub App permissions block comments/edits/closes.
set -euo pipefail

REPO="snackpackgames/ansible"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Syncing resolution for #7 ([Grilling] Combat turn order model, action economy, and squad size)..."
gh api -X POST "repos/$REPO/issues/7/comments" \
  -F body="@$ROOT_DIR/documentation/wayfinder/resolutions/0007-combat-turn-order-action-economy-squad-size.md" >/dev/null
gh api -X PATCH "repos/$REPO/issues/7" -f state=closed -f state_reason=completed >/dev/null

echo "==> Updating Map #6 (Turn-Based Squad Combat System) Decisions-so-far and Not-yet-specified..."
MAP6_BODY=$(cat <<'EOF'
## Destination

**Type:** `afk-implementation`

Turn-based squad-vs-squad line-up combat is fully specified and ready to implement in both the Rust simulation core and Godot 4 client, featuring PlayStation-era Final Fantasy cinematic camera choreography, deterministic turn resolution (Upkeep → Validation → Triggers → Execution → EndTurn), drifter battle classes, and server-validated battle outcomes.

## Notes

- Terminal artifact: `plan(s) in documentation/plans/ + ready-for-agent issue(s)`
- Deliverables are produced only by `/wayfinder-handoff`. This line is orientation, not a *Plan, don't do* override — do not write the plan, the ADR, or the system doc from a `/wayfinder <map>` session.
- Domain: turn-based combat simulation (Rust core), Godot 3D battle staging & cinematic camera rig, enemy AI.

## Decisions so far

<!-- the index — one line per closed ticket: enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [[Grilling] Combat turn order model, action economy, and squad size](https://github.com/snackpackgames/ansible/issues/7) — Dynamic FFX-style CTB Action-Value timeline with variable per-skill recovery weights & live preview; shared 5-chamber Cylinder AP (starts at 3, basics +1, skills spend 1–2); 3+1 Drifter Squad vs. 1–8 enemies (per-enemy cooldowns/intent cycles); bounded FIFO trigger queue (max depth 2) in the 7-stage Turn Pipeline.

## Not yet specified

- Staggered multi-row arena staging and touch target-selection ergonomics for large 5–8 enemy swarms on mobile screens
- Boss encounters, multi-phase enemies, and environmental hazards tied to specific star-map POI types
- Consumable battle items, ammo/reload economy, and synergy combo attacks between paired drifters
- Combat pacing/speed-up toggle (1x / 2x / skip animations) for mobile sessions

## Out of scope

- Real-time action combat or free-roaming grid movement (combat uses cinematic line-up staging)
- Synchronous PvP arena battles (multiplayer focus is async shared squads)
EOF
)
gh api -X PATCH "repos/$REPO/issues/6" -f body="$MAP6_BODY" >/dev/null

echo "==> Syncing resolution for #3 ([Research] Godot 4 Compatibility renderer WebGL2 export & nakama-godot WebSocket auth on browser and mobile)..."
gh api -X POST "repos/$REPO/issues/3/comments" \
  -F body="@$ROOT_DIR/documentation/wayfinder/resolutions/0003-godot4-webgl2-nakama-websocket-auth.md" >/dev/null
gh api -X PATCH "repos/$REPO/issues/3" -f state=closed -f state_reason=completed >/dev/null

echo "==> Updating Map #1 Decisions-so-far with #3..."
MAP1_TMP="$(mktemp)"
gh api "repos/$REPO/issues/1" --jq '.body' > "$MAP1_TMP"
python3 - "$MAP1_TMP" <<'PY'
import sys
p = sys.argv[1]
text = open(p).read()
marker = "<!-- the index — one line per closed ticket: enough to judge relevance, then zoom the link for the detail the ticket holds -->"
entry = "- [[Research] Godot 4 Compatibility renderer WebGL2 export & nakama-godot WebSocket auth on browser and mobile](https://github.com/snackpackgames/ansible/issues/3) — Confirmed `gl_compatibility` + single-threaded Web export (`thread_support=false`, WebAudio `Sample` mode w/ pre-baked FX & gesture unlock), dual VRAM `.pck` duplication guardrails (vertex-color/WebP + Brotli), Compatibility lighting/shader limits, pure-GDScript `heroiclabs/nakama-godot` with stateless HTTPS `client.rpc_async` for turn RPCs + `NakamaSocket` (`wss://`) for push events, UUID device auth (never `OS.get_unique_id()`), email/social linking for Safari 7-day ITP eviction, and 2-token `NakamaSession.new(token, refresh_token)` restore + resume backoff (`documentation/wayfinder/resolutions/0003-godot4-webgl2-nakama-websocket-auth.md`)."
if entry not in text:
    assert marker in text, "Decisions-so-far marker not found in Map #1"
    open(p, "w").write(text.replace(marker, marker + "\n\n" + entry, 1))
PY
gh api -X PATCH "repos/$REPO/issues/1" -F body="@$MAP1_TMP" >/dev/null
rm -f "$MAP1_TMP"

echo "Done! Synced resolutions (#3, #7) and updated Maps #1 & #6 on GitHub."
