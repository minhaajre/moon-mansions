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

## Publishing to the Raycast Store

**This extension is already published.** `extensions/moon-mansions` exists in
`raycast/extensions`, so every PR here is an *update* to a live extension, never a
new addition. Published 2026-10-01.

Before opening any PR, confirm the current store state — do not infer it:

```
gh api repos/raycast/extensions/contents/extensions/moon-mansions   # 404 => new ext
gh api repos/raycast/extensions/compare/raycast:main...main          # fork drift
```

Check `raycast/extensions` **upstream**, never the local fork. The fork is routinely
hundreds of commits behind, so a 404 on the fork's contents API proves nothing about
whether the extension is published. That mistake produced a whole-extension PR where a
5-file feature PR was correct.

Branch from `upstream/main`, not `origin/main`:

```
git fetch --filter=blob:none upstream main --depth=1
git checkout -B <branch> upstream/main
git sparse-checkout set extensions/moon-mansions
```

`mergeable_state: dirty` on a Raycast PR means the fork is behind, not that the change is wrong.

### CHANGELOG rules

Never rewrite a released version entry. Add a new `## [<what changed>] - {PR_MERGE_DATE}`
block **on top** and leave released entries byte-identical. The `changelog` CI job enforces
this. `{PR_MERGE_DATE}` is the intended placeholder for the entry under review; released
entries carry their real merge date.

### When `ray publish` fails with a 422 on `workflow` scope

GitHub refuses `merge-upstream` for any OAuth token lacking the `workflow` scope, and the
Raycast CLI hardcodes `scope: "repo"` in its device flow — so re-authenticating cannot fix
it. Push to the fork with `gh` (whose token carries `workflow`) and open the PR with
`gh pr create`. Do not retry `npm run publish` for this error.

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
