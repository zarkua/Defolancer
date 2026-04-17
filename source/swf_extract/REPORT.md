# Machinations SWF Baseline

This folder contains the extracted baseline from `source/Machinations.swf`.

## What was recovered

- Full AS3 class list via FFDec CLI.
- Decompiled ActionScript sources in `source/swf_extract/ffdec_export/scripts/`.
- XML dump of the SWF in `source/swf_extract/machinations.xml`.
- SWF tag dump in `source/swf_extract/dump_swf.txt`.
- AS3 symbol dump in `source/swf_extract/dump_as3.txt`.
- A browser preview page for the old offline client in `source/swf_extract/ruffle_preview.html`.

## Key classes recovered

- `nl.jorisdormans.machinations.controller.MachinationsController`
- `nl.jorisdormans.machinations.model.MachinationsGraph`
- `nl.jorisdormans.machinations.model.MachinationsNode`
- `Pool`, `Source`, `Drain`, `Converter`, `Trader`
- `Gate`, `Delay`, `Register`, `Chart`, `EndCondition`
- `ResourceConnection`, `StateConnection`
- `MachinationsExpression`, `MachinationsScriptExpression`
- `MachinationsEditView`, `MachinationsView`, `MachinationsDraw`

## UI findings from the offline editor

- Top bar with `Run (R)` and the title `Machinations v4.05 by Joris Dormans (2009-2013), www.jorisdormans.nl/machinations`.
- Right-side tab strip: `Graph`, `Edit`, `File`, `Run`.
- `Graph` tab contains a 4x4 tool grid:
  - `Select`, `TextL`, `GroupBox`, `Chart`
  - `Pool`, `Gate`, `Resource Connection`, `State Connection`
  - `Source`, `Drain`, `Converter`, `Trader`
  - `Delay`, `Register`, `EndCondition`, `ArtificialPlayer`
- `Edit` tab buttons:
  - `Select All (A)`, `Copy (C)`, `Paste (V)`, `Undo (Z)`, `Redo (Y)`, `Zoom (M)`
- `File` tab buttons:
  - `New (N)`, `Open (O)`, `Import (I)`, `Save (S)`, `Export Selection (E)`, `Save as SVG (G)`
- `Run` tab buttons:
  - `Quick Run`, `Multiple Runs`, `Runs`, `Visible Runs`

## XML format findings

The old offline client serializes diagrams as XML and upgrades older files through:

- `XMLConverter.convertV2V30`
- `XMLConverter.convertV30V35`
- `XMLConverter.convertV35V40`

Recovered XML graph-level fields include:

- `version`
- `name`
- `author`
- `interval`
- `timeMode`
- `actions`
- `distributionMode`
- `speed`
- `dice`
- `skill`
- `strategy`
- `multiplayer`
- `width`
- `height`
- `numberOfRuns`
- `visibleRuns`

Recovered node-level fields include:

- `symbol`
- `x`, `y`
- `color`
- `caption`
- `thickness`
- `captionPos`
- `interactive`
- `actions`
- `resourceColor`
- `startingResources`
- `maxResources`
- `gateType`
- `scaleX`, `scaleY`

## Re-run extraction

From the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\extract_machinations_swf.ps1
```
