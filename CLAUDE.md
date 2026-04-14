# The Flutiano — Project Rules

## Stack
- Vanilla HTML + CSS + JS only. No framework. No build tool.
- 3 files: `dashboard.html`, `projects.html`, `new-project.html`
- All styles inline in `<style>` per page (no shared CSS file yet)

## Design System Tokens (all 3 pages share these)
```
--bg: #06050d          body background
--gold: #D4AA6A        primary accent
--gold-hi: #EACC96     gold highlight
--gold-lo: rgba(212,170,106,0.15)  gold tint
--jade: #5EC997        active/progress
--sky: #7ABCE8         draft/concept
--rose: #F07575        warning/missing
--t1: #FFFFFF          primary text
--t2: rgba(255,255,255,0.72)   secondary text
--t3: rgba(255,255,255,0.45)   tertiary text
--t4: rgba(255,255,255,0.28)   muted text
--b0: rgba(255,255,255,0.08)   subtle border
--b1: rgba(255,255,255,0.14)   visible border
--sw: 244px            sidebar width
--th: 64px             topbar height
--r: 14px              card radius
--rs: 9px              small radius
```

## Card / Panel Standard (as of Phase 1+2)
```css
background: rgba(255,255,255,0.07);
border: 1px solid rgba(255,255,255,0.14);
backdrop-filter: blur(20px) saturate(160%);
border-radius: var(--r);
```

## Rules
- Never change token values without updating all 3 pages
- Brand block is always `<a href="dashboard.html">` with "The Flutiano" / "Creative System"
- Brand SVG icon: flute-like path + 2 circles, stroke #D4AA6A
- Active nav item: class `active` → `background: var(--gold-lo); color: var(--gold)`
- Proj-action text: always `var(--t2)` (not t3)
- Section labels: `rgba(255,255,255,0.62)` uppercase tracking
- Make fewest possible changes. CSS-only when possible.
- Do not introduce JS libraries or external dependencies
