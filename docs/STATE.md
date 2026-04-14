# Project State — The Flutiano

## Completed
- **Phase 1** `dashboard.html` — contrast improvements applied
  - Card bg: 5%→7% white, border: 9%→14% white
  - Section labels: t3→62% white
  - proj-action: t3→t2
  - Body text (week/missing/continue/library): t2→90% white
- **Phase 2** `projects.html` — aligned with dashboard visual language
  - stat-card bg: 4%→7%, border: b0→b1
  - proj-card-full bg: 5%→7%, border: 9%→14%
  - proj-action: t3→t2

## Current Status
All 3 pages are functional and visually consistent. Layout is still fully duplicated (CSS, sidebar HTML, project data all copy-pasted across files).

## Pending (not started)
- **Phase 4** Extract `shared.css` — deduplicate ~200 lines of identical CSS tokens + sidebar/topbar/card base styles
- **Phase 5** Extract `sidebar.js` — one source of truth for sidebar HTML; set active item from `location.pathname`
- **Phase 6** Extract `project-data.js` — 5 project objects used by both dashboard (3-card) and projects (full grid)

## Next Recommended Step
Phase 4: Extract `shared.css` with all design tokens, sidebar, topbar, card base styles. Each page `<link>`s it and keeps only page-specific styles inline.
