# Agent Issue Triage State Machine

Used by `/triage`, `/to-spec`, and automated GitHub Actions workflows.

| Label | Meaning | Next Actor |
| :--- | :--- | :--- |
| `needs-grilling` | Idea or bug report lacks settled domain terms or seams. | Human + `/grill-with-docs` |
| `spec` | Parent specification issue containing user stories, seams, and testing decisions. | Human / `/to-tickets` |
| `blocked` | Ticket has unresolved upstream blocking edges. | Wait for upstream ticket |
| `ready-for-agent` | Self-contained `<150k`-token tracer-bullet ticket ready for autonomous execution. | Coding Agent / Sandcastle CI |
| `in-review` | PR opened with visual summary, runtime evidence, and merge-danger assessment. | `/code-review` + Human |
