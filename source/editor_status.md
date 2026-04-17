# Machinations Editor Status

## Current startup path

- Bootstrap: `/main/main.collection`
- Main script opens: `machinations_editor`
- Active screen collection:
  - `/screens/machinations_editor/machinations_editor.collection`

## Editor capabilities implemented

- Infinite canvas camera:
  - pan by dragging empty space or right-mouse drag
  - zoom by mouse wheel
- Node interaction:
  - select node by click
  - drag selected node
  - delete selected node
- Graph editing:
  - add node types (source/pool/gate/drain/queue/delay/register)
  - arm link mode and create resource connection by clicking target node
- Simulation:
  - single-step execution
  - autoplay stepping
  - batch run (Monte Carlo style)
- Persistence:
  - load diagram from `source/diagrams/hourglass.json`
  - save editor snapshot to `source/diagrams/editor_snapshot.json`
  - save batch report to `source/latest_batch_report.json`

## Hotkeys

- `Space` - step simulation
- `Enter` - toggle autoplay
- `B` - batch run
- `N` - add pool
- `S` - add source
- `G` - add gate
- `D` - add drain
- `Q` - add queue
- `E` - add delay
- `V` - add register
- `C` - arm link mode from selected node
- `Delete` / `Backspace` - delete selected node
- `R` - reset to initial loaded diagram
- `L` - reload sample diagram
- `K` - save editor snapshot

## Notes

- UI layer (`.gui_script`) is message-driven and does not require game-logic modules directly.
- Core simulation is handled by modules in `modules/machinations/*`.
