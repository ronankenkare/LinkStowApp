# LinkStow Repository Guidance

## Systems documentation

The HTML systems documentation in `docs/` describes the application as it is
currently implemented. Update the relevant documentation whenever a change
materially affects any of the following:

- System boundaries, external actors, platform services, or integrations
- Component responsibilities, dependencies, or data flow
- Link creation, metadata retrieval, editing, or persistence behavior
- SwiftData models, relationships, invariants, or deletion rules
- Main-screen states, transitions, filtering, sorting, or error paths
- Hidden-link authentication, authorization, visibility, or trust boundaries

Keep the existing diagram categories unless the project explicitly adopts a
different documentation structure:

- System context
- Component architecture
- Save-link flow
- Data model
- Main state machine
- Hidden-link security

Treat the source code and passing tests as the source of truth. Diagrams must
distinguish current behavior from planned, dormant, or partially implemented
behavior. Do not document a planned feature as operational.

Purely cosmetic changes that do not affect system behavior or interfaces do not
require diagram updates.

## Documentation verification

When changing `docs/`:

- Keep navigation and previous/next links valid.
- Keep Mermaid available from `docs/vendor/mermaid.min.js` so diagrams work from
  local `file://` pages.
- Preserve the expand, zoom, and pan behavior provided by `docs/diagrams.js`.
- Check HTML and JavaScript syntax and run `git diff --check`.
