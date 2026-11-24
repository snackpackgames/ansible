# Resolution: [Research] Godot 4 Compatibility renderer WebGL2 export & nakama-godot WebSocket auth on browser and mobile (#3)

- **Parent Map:** [Map: Core Architecture, Nakama + Rust WASM Backend & Web/Mobile Pipeline](https://github.com/snackpackgames/ansible/issues/1) (`#1`)
- **Ticket:** [[Research] Godot 4 Compatibility renderer WebGL2 export & nakama-godot WebSocket auth on browser and mobile](https://github.com/snackpackgames/ansible/issues/3) (`#3`)
- **Resolved:** 2026-11-23

---

## Executive Summary

| Area | Verified Decision / Setting | Key Constraint / Action Item |
|---|---|---|
| **Renderer** | `gl_compatibility` on Desktop, Web, and Mobile | Only renderer supported on Web (WebGL 2.0; Godot 4 has no WebGPU backend for Forward+/Mobile). Keeping `gl_compatibility` on mobile guarantees visual parity across Browser, iOS, and Android. |
| **Web Export Threading** | `variant/thread_support=false`, `variant/extensions_support=false` | Eliminates `SharedArrayBuffer` / `COOP`+`COEP` header requirements, avoids macOS/iOS Safari multi-threaded Web bugs, and works on any static host/embed. |
| **Web Audio Playback** | Default Web Audio API `Sample` mode + pre-baked audio FX + gesture unlock | Single-threaded Web `Sample` mode does **not** support `AudioEffect` bus effects (Reverb, EQ, Compressor, Delay), Doppler, or procedural audio (`AudioStreamGenerator`). Bake synth-western FX offline and unlock audio on first tap/click. |
| **VRAM Texture Compression** | Pin both `import_s3tc_bptc=true` & `import_etc2_astc=true`; minimize VRAM-compressed textures on Web | Enabling both `for_desktop=true` and `for_mobile=true` in one Web preset duplicates every VRAM-compressed texture inside the `.pck`. Lean on vertex-color shaders + Lossless/Lossy WebP for 2D/UI, reserve VRAM compression (or Basis Universal) for 3D maps, and serve `.wasm`/`.pck` with Brotli/Gzip. |
| **Shader & Lighting Budget** | Max 8 Omni + 8 Spot lights per mesh (target ≤ 1 shadowed `DirectionalLight3D` + ≤ 4 unshadowed fill lights); zero RD-only features | No `Decal`, `VoxelGI`, `SDFGI`, `VolumetricFog`, `SSR`/`SSAO`/`SSIL`, compute shaders, PCSS, or textured area lights. Existing `drifter_recolor.gdshader` and `neon_western_holo.gdshader` are verified WebGL 2.0 safe. |
| **Nakama SDK & Transport** | Pure-GDScript `heroiclabs/nakama-godot` (`v3.4.0+` / Godot 4 `master`) — **HTTPS `client.rpc_async` for turn/async RPCs**, **`NakamaSocket` (`wss://`) for push notifications** | Stateless HTTPS RPCs inherit `nakama-godot`'s auto-refresh + network retry and survive Safari/mobile tab suspension; keep `socket` as a Node/Autoload member var (never local) and reconnect on focus/resume with exponential backoff + jitter. |
| **Auth & Session Lifecycle** | Generated UUID v4 stored in `user://` (never `OS.get_unique_id()`), **prompt Web players to link Email/Social**, restore sessions with **both** `token` and `refresh_token` | `OS.get_unique_id()` is insecure on mobile and unavailable on Web; Safari WebKit ITP evicts `user://` IndexedDB after **7 days** of inactivity (exempt only for Home Screen PWAs). Work around `nakama-godot#207` by restoring via `NakamaSession.new(auth_token, refresh_token)`. |

---

## 1. Godot 4 Compatibility Renderer & Single-Threaded WebGL2 Export

### Audit of Current Repo Configuration (`client/project.godot` & `client/export_presets.cfg`)

| Setting | Current Value | Verdict & Required Adjustment |
|---|---|---|
| `rendering/renderer/rendering_method` | `"gl_compatibility"` | **Confirmed.** Required for WebGL 2.0 ([Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)). |
| `rendering/renderer/rendering_method.mobile` | `"gl_compatibility"` | **Confirmed.** Keeps lighting/shader parity with Web and runs on older mobile GPUs without Vulkan/Metal. |
| `rendering/textures/vram_compression/import_etc2_astc` | `true` | **Confirmed.** Required for mobile WebGL2, iOS, and Android. |
| `rendering/textures/vram_compression/import_s3tc_bptc` | *(implicit default)* | **Action:** Explicitly set `textures/vram_compression/import_s3tc_bptc=true` in `client/project.godot` so desktop WebGL2 compression intent is explicit. |
| `variant/thread_support` (Web preset) | `false` | **Confirmed.** Default since Godot 4.3; avoids `COOP`/`COEP` `SharedArrayBuffer` headers and Safari iOS/macOS threading issues ([Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)). |
| `variant/extensions_support` (Web preset) | `false` | **Confirmed.** Enabling GDExtension on Web re-introduces the `COOP`/`COEP` cross-origin isolation requirement. |
| `vram_texture_compression/for_desktop` & `for_mobile` | Both `true` | **Confirmed with budget caveat** (see VRAM section below). |
| `html/canvas_resize_policy` | `2` (Adaptive) | **Confirmed.** Matches browser viewport dynamically across desktop & mobile orientation changes. |
| `html/experimental_virtual_keyboard` | `false` | **Confirmed for now.** Only enable (and test on iOS Safari) once Web text inputs (email/handle/friend code) are added, or provide a `JavaScriptBridge` prompt fallback. |
| `export_path` | `"export/web/index.html"` | **Confirmed.** Keep exported basenames intact (`index.html`, `index.js`, `index.wasm`, `index.pck`) — Godot 4's Web loader breaks if exported filenames are renamed post-export. |

### Single-Threaded Web Audio Constraints (Informs Map #30 / Ticket #33)

Per [Exporting for the Web — Audio](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html):
- Since Godot 4.3, Web exports without threads default to **Web Audio API `Sample` playback mode** for low latency.
- **`Sample` mode limitations:**
  - `AudioEffect` bus effects (Reverb, Delay, Compressor, Distortion, EQ) are **not supported**.
  - Reverberation and Doppler effects are **not supported**.
  - Procedural audio generation (`AudioStreamGenerator`) is **not supported**.
  - Positional 3D audio may not behave consistently.
- Switching `Audio > General > Default Playback Type.web` to `Stream` re-enables Godot's mixer/effects, but adds noticeable audio latency when `thread_support=false`.
- **Policy for Ansible:** Keep `Sample` mode on Web, **pre-bake synth-spaghetti western reverb/delay/EQ offline into Ogg Vorbis / WAV assets**, and unlock browser WebAudio on the player's first tap/click (required by Chrome & Safari autoplay policies).

### VRAM Texture Compression & Web Download Budget

Per [Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html):
- Enabling both `for_desktop=true` (S3TC/BPTC) and `for_mobile=true` (ETC2/ASTC) in a single Web export produces maximum cross-device GPU compatibility, **at the cost of bundling both compressed copies of every VRAM-compressed texture in the `.pck`**.
- **Rules for Ansible's asset pipeline:**
  1. **Prefer vertex-color + procedural shaders** (`drifter_recolor.gdshader`, `neon_western_holo.gdshader`) for characters and holographic UI — zero texture bloat in `.pck`.
  2. **2D UI / icons / portraits:** Import as **Lossless** or **Lossy (WebP)** rather than VRAM Compressed so they are stored once and avoid S3TC+ETC2 duplication.
  3. **3D environment / prop textures:** Keep resolutions compact (256–512 px for stylized low-poly assets) and evaluate **Basis Universal** if texture count grows large enough to threaten mobile download budgets.
  4. **Web server delivery:** Always serve `.wasm` and `.pck` with **Brotli (`.br`) or Gzip** compression (`application/wasm` MIME type for `.wasm`). Godot's `.wasm` compresses to ~25% of uncompressed size with gzip and smaller with Brotli.
  5. **Optional future optimization:** Build a stripped Web export template (disabling unused 2D/3D physics/XR modules) to shrink initial mobile Web download size.

### Compatibility Renderer (WebGL 2.0 / GLES 3.0) Shader & Feature Constraints

Per [Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html), [Environment and post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html), [3D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html), and [Screen-reading shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html):

- **Light & reflection budgets:**
  - Max **8 `OmniLight3D` + 8 `SpotLight3D` per mesh** (and 8 `DirectionalLight3D`); lights with shadows fall back to a multi-pass path with less accurate blending.
  - Max **2 `ReflectionProbe`s per mesh**.
  - **PCSS soft shadows** and **textured area lights** are unsupported.
  - *Audit of `client/scripts/battle_scene_controller.gd`:* Currently uses 1 shadow-casting `DirectionalLight3D` + 2 unshadowed `OmniLight3D`s + `ProceduralSkyMaterial` + distance fog — **fully compliant**. Enforce a budget of **1 shadowed `DirectionalLight3D` + ≤ 4 unshadowed fill/accent lights** per battle arena.
- **Banned RenderingDevice-only features (unsupported in Compatibility):**
  - `Decal` nodes, `VoxelGI`, `SDFGI`, `VolumetricFog` / `FogVolume`, `SSR`, `SSAO`, `SSIL`, compute shaders, `CompositorEffect` RD pipelines, and `FSR2`/`MetalFX` upscalers.
- **Glow / Bloom (`WorldEnvironment`):**
  - Compatibility uses a simplified glow pipeline with several Inspector properties (`Levels`, etc.) unavailable.
  - Pair subtle `WorldEnvironment` glow with **shader-driven additive rim/border glow** (already demonstrated in `drifter_recolor.gdshader` and `neon_western_holo.gdshader`) so the Neon Spaghetti Western look holds up consistently on mobile WebGL 2.0.
- **Shader precision & screen-texture hygiene:**
  - Audit of existing shaders: `client/shaders/drifter_recolor.gdshader` (`diffuse_toon`, `specular_toon`, 4-channel `COLOR` mask, Fresnel rim) and `client/shaders/neon_western_holo.gdshader` (procedural `UV`/`TIME` scanlines + border glow) are **100% WebGL 2.0 / GLES 3.0 safe**.
  - Avoid `hint_screen_texture` on stacked transparent effects (triggers full-screen back-buffer copies and degrades mobile fill rate).
  - Be mindful of `mediump` fragment float precision on mobile GLES3/WebGL2 GPUs — wrap `TIME` (`mod(TIME, 1000.0)`) or annotate `highp` on long-running time/UV accumulators so scanlines don't jitter after long play sessions.
- **Safari WebGL 2.0 QA Gate:**
  - Official Godot docs explicitly warn that Safari has WebGL 2.0 quirks not seen in Chromium or Firefox ([Exporting for the Web — WebGL version](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)). Any new 3D shader, post-processing pass, or Web UI milestone must be smoke-tested on **iOS Safari** in addition to desktop Chromium.

---

## 2. `heroiclabs/nakama-godot` WebSocket & HTTPS Session Lifecycle (Browser, iOS, Android)

### SDK Fit & Single-Threaded Web Compatibility

Per [`heroiclabs/nakama-godot`](https://github.com/heroiclabs/nakama-godot) and [Heroic Labs: Nakama Godot 4 Client Guide](https://heroiclabs.com/docs/nakama/client-libraries/godot/):
- The `master` branch (`v3.4.0+`) is written in **100% pure GDScript for Godot 4.0+** (no GDExtension / C# runtime required), using Godot's built-in `HTTPRequest` (`NakamaHTTPAdapter`) and `WebSocketPeer` (`NakamaWebSocketAdapter`).
- Installed by vendoring `addons/com.heroiclabs.nakama/` and registering `Nakama.gd` as an autoload singleton.
- **Single-threaded Web export safety:** `nakama-godot` explicitly disables `HTTPRequest.use_threads` on HTML5/Web exports ([`CHANGELOG.md`](https://github.com/heroiclabs/nakama-godot/blob/master/CHANGELOG.md)), matching Godot's Web restriction that threaded/blocking HTTP mode is unavailable and HTTP progresses once per frame ([Exporting for the Web — Networking](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)).
- **Audit of `client/scripts/net/nakama_client_adapter.gd`:** Currently a minimal prototype stub that opens a raw `WebSocketPeer` without HTTP authentication, JWT refresh, or `nakama-godot` integration. It should be upgraded to wrap `NakamaClient` + `NakamaSocket` cleanly while preserving its offline local-simulation fallback (`BattleEngine`).

### Identity & Device Auth Rules (Web vs. iOS / Android)

1. **Never pass `OS.get_unique_id()` to `authenticate_device_async`:**
   - Heroic Labs' [Authentication docs](https://heroiclabs.com/docs/nakama/concepts/authentication/) explicitly advise **against** `OS.get_unique_id()` in Godot because OS hardware IDs can be read by other apps on mobile (impersonation risk), and on Web exports hardware IDs are unavailable.
   - Instead, generate a cryptographically random UUID v4 (`Crypto.new().generate_random_bytes(16)` or `nakama-godot`'s `Nakama.get_device_id()` helper on `master`) on first launch and persist it in private `user://` storage.
2. **Safari WebKit ITP 7-Day Storage Eviction (Critical for Mobile & Desktop Safari Web Players):**
   - On Web exports, Godot's `user://` filesystem is backed by browser **IndexedDB** ([Exporting for the Web — Data persistence](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)).
   - Per [WebKit Tracking Prevention](https://webkit.org/tracking-prevention/), **Safari deletes all script-writable storage (IndexedDB, `localStorage`, Service Worker cache) after 7 days without user interaction on the site**. Only first-party domains added to the iOS Home Screen (PWA) are exempt from the 7-day cap; Incognito/private tabs and third-party iframes disable persistence altogether, and `OS.is_userfs_persistent()` can return false positives.
   - **Required UX & Auth Flow:**
     - Allow instant frictionless start via stored UUID device auth (`authenticate_device_async`).
     - Prompt Web players (and offer in Settings on all platforms) to **link an Email/Password or social login** (`link_email_async` / Apple / Google) after their first Expedition so their Ansible outpost & Drifter roster survive Safari 7-day wipes and sync across Browser, iOS, and Android ([Authentication — Ways to associate an identifier](https://heroiclabs.com/docs/nakama/concepts/authentication/)).

### Session Restore, Token Refresh & Known `nakama-godot` Pitfall

- `nakama-godot` (`v3.0.0+`) supports JWT `auth_token` + `refresh_token`, automatic session refresh on API calls, and automatic network-error retries (`session_refresh_async`; [`CHANGELOG.md`](https://github.com/heroiclabs/nakama-godot/blob/master/CHANGELOG.md)).
- **Known SDK Bug ([`heroiclabs/nakama-godot#207`](https://github.com/heroiclabs/nakama-godot/issues/207)):** In `v3.4.0`, `NakamaClient.restore_session(auth_token)` omitted `refresh_token`, causing subsequent `session_refresh_async(session)` calls to fail with `Refresh token is required`.
- **Canonical Startup Lifecycle in `NakamaClientAdapter`:**
  1. Persist **both** `session.token` and `session.refresh_token` in `user://` (encrypted/obfuscated `ConfigFile` on native mobile; standard `user://` JSON on Web).
  2. Restore using `NakamaSession.new(auth_token, refresh_token)` (verifying the 2-arg signature when vendoring `nakama-godot`).
  3. On boot / resume:
     - If `session == null` or `session.is_refresh_expired()`: re-authenticate via stored device UUID (or linked credentials).
     - Else if `session.is_expired()` (or within 5 minutes of expiry): call `await client.session_refresh_async(session)` and persist the rotated tokens before making RPCs or opening a socket.

### Transport Split: HTTPS RPCs vs. Persistent WebSocket (`NakamaSocket`)

- **Use stateless HTTPS `client.rpc_async(session, rpc_id, payload_json)` for all turn-based gameplay & async co-op calls** (`ansible_battle_start`, `ansible_battle_step`, expedition node resolution, outpost advance, shared-squad publish/borrow):
  - Automatically leverages `nakama-godot` JWT auto-refresh and transient network retry.
  - Never blocks or fails solely because a mobile OS or Safari background tab killed the WebSocket 10 seconds earlier.
- **Use persistent `NakamaSocket` (`wss://`) for real-time push events** (friend requests, shared-squad borrow notifications, inbox/presence updates):
  - Always hold `socket` as a **Node/Autoload member variable** — never a local function variable, or GDScript `RefCounted` GC immediately closes the connection when the function returns ([Nakama Godot 4 Client Guide](https://heroiclabs.com/docs/nakama/client-libraries/godot/), [`nakama-godot#13`](https://github.com/heroiclabs/nakama-godot/issues/13)).
  - Do **not** use `NakamaMultiplayerBridge` (designed for relayed Godot High-Level Multiplayer, not server-authoritative turn-based RPCs; [`nakama-godot#179`](https://github.com/heroiclabs/nakama-godot/issues/179)).

### Mobile & Browser Suspend/Resume Reconnection Lifecycle

- **Browser background tabs:** Browsers pause `_process()` when a tab is inactive, stopping `WebSocketPeer.poll()` so Nakama closes the idle socket ([Exporting for the Web — Background processing](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)).
- **iOS & Android backgrounding:** Apps may be suspended or killed without a quit event; flush local caches on `NOTIFICATION_APPLICATION_PAUSED` ([Handling quit requests](https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html)).
- **Required Reconnection State Machine in `NakamaClientAdapter`:**
  1. Subscribe to `NOTIFICATION_APPLICATION_PAUSED` (flush pending local cache), `NOTIFICATION_APPLICATION_RESUMED` & `NOTIFICATION_APPLICATION_FOCUS_IN` (native iOS/Android), and `JavaScriptBridge` `document.addEventListener("visibilitychange", ...)` (Web).
  2. Subscribe to `socket.closed` (handle uniformly even when `get_close_code()` returns `0`/`-1` on abrupt cellular/Wi-Fi drops; [`nakama-godot#217`](https://github.com/heroiclabs/nakama-godot/issues/217)).
  3. On resume or `socket.closed`: check `session.is_expired()` → refresh JWT → reconnect `NakamaSocket` with **exponential backoff + jitter** (`1s → 2s → 4s → 8s → 30s` cap) → re-fetch authoritative state snapshot over HTTPS RPC if a turn/expedition was in flight.

### TLS, Mixed Content & CORS Requirements

- **Mixed Content (Browser):** Any Web build served over `https://` **must** use `https` + `wss` (`use_ssl = true`). Auto-detect via `OS.has_feature("web")` + `JavaScriptBridge.eval("window.location.protocol === 'https:'")` so `http`/`ws` is only used on `localhost`/`127.0.0.1`.
- **CORS & WebSocket Upgrade (Server/Proxy):** Production reverse proxies in front of Nakama (Nginx/Caddy/Cloudflare/Heroic Cloud) must forward CORS preflight `OPTIONS` requests (`Authorization`, `Content-Type`) and `Upgrade: websocket` / `Connection: Upgrade` headers for `/ws` ([`nakama-godot#30`](https://github.com/heroiclabs/nakama-godot/issues/30)).
- **Secrets hygiene:** Never ship `"defaultkey"` in release exports; configure `server_key` and host per environment via build config/feature tags.

---

## 3. Map & Downstream Impact

- **Unblocks Ticket #4:** With **[[Research] Nakama Go + Rust WASM (wazero/extism) runtime ABI and dev workflow](https://github.com/snackpackgames/ansible/issues/2)** (`#2`) and this ticket (`#3`) both resolved, **[[Grilling] Authoritative vs. optimistic client-server boundaries for offline-tolerant mobile play](https://github.com/snackpackgames/ansible/issues/4)** (`#4`) is now **unblocked** and enters the Map #1 frontier!
- **Informs Ticket #33 (Map #30):** Single-threaded Web `Sample` audio disables live `AudioEffect` bus processing and requires first-gesture WebAudio unlock.
- **Informs Map #1 `Not yet specified`:** Clarified VRAM `.pck` duplication vs. WebP/vertex-color/Brotli strategy; concrete mobile download size budget remains in `Not yet specified` until 3D/audio asset production scales up.

---

## 4. Primary Sources Cited

- Godot Engine Docs, *Exporting for the Web*: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Godot Engine Docs, *Overview of renderers*: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot Engine Docs, *Environment and post-processing*: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- Godot Engine Docs, *3D lights and shadows*: https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html
- Godot Engine Docs, *Screen-reading shaders*: https://docs.godotengine.org/en/stable/tutorials/shaders/screen-reading_shaders.html
- Godot Engine Docs, *Internal rendering architecture*: https://docs.godotengine.org/en/4.4/contributing/development/core_and_modules/internal_rendering_architecture.html
- Godot Engine Docs, *Handling quit requests* (`NOTIFICATION_APPLICATION_PAUSED`): https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html
- Heroic Labs, *Nakama Godot 4 Client Guide*: https://heroiclabs.com/docs/nakama/client-libraries/godot/
- Heroic Labs, *Authentication* (Device ID security & account linking): https://heroiclabs.com/docs/nakama/concepts/authentication/
- `heroiclabs/nakama-godot` repository & changelog: https://github.com/heroiclabs/nakama-godot and https://github.com/heroiclabs/nakama-godot/blob/master/CHANGELOG.md
- `heroiclabs/nakama-godot` issues: [#13](https://github.com/heroiclabs/nakama-godot/issues/13), [#30](https://github.com/heroiclabs/nakama-godot/issues/30), [#179](https://github.com/heroiclabs/nakama-godot/issues/179), [#207](https://github.com/heroiclabs/nakama-godot/issues/207), [#217](https://github.com/heroiclabs/nakama-godot/issues/217)
- WebKit, *Tracking Prevention* (7-day cap on script-writable storage / IndexedDB & Home Screen PWA exemption): https://webkit.org/tracking-prevention/
