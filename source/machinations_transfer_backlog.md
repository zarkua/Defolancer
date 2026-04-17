# Machinations Transfer Backlog

Based on local corpus in `source/raw/*` and current implementation in `modules/machinations/*`.

## P0 (next)

- Converter/Trader full semantics (multi-input/output contracts).
- Gate subtypes hard constraints:
  - sorting gates
  - mixed gates
  - trigger gates
- Delay vs Queue strict distinction (FIFO queue behavior).
- Resource connection semantics completion (typed resources + stricter transfer rules).
- State connection action matrix completion.
- Trigger/activator wrappers as first-class schema objects.
- Play modes completion for runtime/editor-level flow (step/interactive/batch parity).
- Formula layer expansion for custom variables and randomness parity.
- Pull/push behavior hardening and tests.

## P1

- Math.js compatibility expansion (functions + advanced structures).
- Labels/types/intervals parser support.
- Custom resources and filtering model (non-scalar resource packets).
- Charts/accuracy/distribution metrics layer on top of batch runs.
- Debugger rule engine and richer warning/error streams.
- History/snapshot persistence and replay tooling.
- External data adapters:
  - external JSON
  - sheets-like adapters
  - market feed adapters
- Local API/bridge layer for integrations and data handoff.
- Defold runtime integration adapter module.

## P2

- Public share/embed export surfaces for local mode.
- Optimizer/Balancer module (post-kernel stabilization).

## SaaS-only / Not 1:1

- Browser collaboration, team management, SSO/SAML, cloud-hosted sync.
- Official hosted API/backend internals and productized enterprise controls.
- Must stay clean-room reimplementation of semantics, not backend cloning.
