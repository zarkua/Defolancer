# Machinations implementation summary

- Core nodes: define the simulation graph, resource containers, transfers, gate logic, delay/queue behavior, activators, and node/label modifiers. This is the structural model the reimplementation must preserve.
- Triggers / play modes: specify when nodes fire, how resource movement is initiated, and how different execution modes affect scheduling and turn resolution.
- Formulas / variables: define the expression language, custom variables, randomness, and external data inputs that feed node logic and balancing rules.
- Charts / debugger: describe observability features needed for simulation validation, including time-series output, Monte Carlo runs, accuracy signals, and step-by-step debugging.
- Integrations / API: cover import/export surfaces and sync points with spreadsheets, external engines, collaboration systems, and public diagram sharing.
- Legal / TOS / public statements: establish product boundaries, terminology, plan constraints, and any public-facing claims that should not be contradicted by the clean-room implementation.
