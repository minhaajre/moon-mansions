# moon-mansions

Raycast extension: moon phase + illumination % + tropical zodiac + Abu Ma'shar 28 lunar mansion (Manazil al-Qamar).

## Stack
TypeScript + `@raycast/api`. Zero runtime astro deps — math ported from `28LunarMansionGuide/index.html` (Meeus Ch.47 truncation, ±1–2°, cross-checked vs AstroSeek).

## Run
`npm install && npm run dev`, then search Raycast for "Moon".

After every src edit: `npm run build` (`ray build -e dist`) rebuilds and installs straight into
`~/.config/raycast/extensions/moon-mansions/`. Verified 2026-09-25: no `ray develop` process
running, installed bundle still refreshed — so `ray develop` is not required. Then re-open the
menu-bar dropdown; it caches on its `1h` interval.

## Key files
- `src/moon.ts` — `moonLon`, `sunLon`, phase + waxing/waning `trend`, zodiac, `lonToMansion`, `getVocInfo`, `vocEndLabel`, MANSIONS data. Do not retune constants without cross-validating 3 dates vs Stellarium/AstroSeek.
- `src/systems.ts` — generated Vedic/Chinese lookups. Regenerate from IbnArbi data, never hand-edit.
- `src/info.tsx` — Detail view command.
- `src/menu-bar.tsx` — menu-bar command (`interval: 1h`).
- `parity/fixture.json` — GENERATED cross-port assertion surface. Never hand-edit.
- `scripts/gen-parity.mts` — regenerates the fixture from this core.
- `scripts/parity-check.sh` — drift gate across all three ports.
- `scripts/install-hooks.sh` — installs the pre-commit gate in all three repos.

## Canonical position in the port family

**This repo is the single source of truth for the astronomy core.** Three ports
consume it; none of them may diverge silently.

| Repo | Relationship | Sync mechanism |
|---|---|---|
| `moon-mansions` (this) | canonical core + fixture generator | — |
| `moon-mansions-chrome` | TypeScript, same language | `npm run sync` byte-copies `moon.ts` / `systems.ts` / fixture |
| `moon-mansions-mac` | hand-ported Swift | `parity.sh` asserts against the fixture |

## Changing the core — mandatory follow-through

A change to `src/moon.ts` is **not done** until both sibling ports match. This
is the rule that was violated before: VOC shipped here while the macOS app
silently lacked it entirely.

1. `npm run parity:gen` — regenerate `parity/fixture.json` from the new core.
2. `npm run parity` — drift gate. Fixes any port it reports.
3. `cd ../moon-mansions-chrome && npm run sync && npm test`
4. `cd ../moon-mansions-mac && cp ../moon-mansions/parity/fixture.json parity/ && ./parity.sh`
5. `npm run build` to refresh the installed Raycast bundle.

New feature or field in `moon.ts` → port it to `MoonMansions/MoonCalc.swift` and
render it in `MoonApp.swift` in the same session. If a Swift port is genuinely
impossible, say so explicitly rather than letting the gate rot.

Run `npm run hooks:install` once per clone (hooks are not versioned).

## Compliance checklist (global AGENTS.md, applied every session without prompting)
- [ ] Read file + grep callers before changing behavior
- [ ] Edit only the block needing change; show modified snippet only
- [ ] User decisions as multichoice popup (2–5 options), never prose
- [ ] Complex work: 2–4 bullet plan, then execute; pause only on irreversible steps
- [ ] After Read: one-sentence finding. After Bash: key result. After Write/Edit: filename
- [ ] Distinguish implemented ≠ verified ≠ tested; verify by execution
- [ ] No AI slop, no banned phrases, no emojis in chat
- [ ] Ask one precise question when in doubt; act without asking when sure
- [ ] End with single one-liner status
