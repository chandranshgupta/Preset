# FLOW — how the system executes

<!-- Answers: "if event X happens, what runs next, which functions and modules, what state changes,
     what I/O occurs, what output is emitted?" — without guessing.
     Describe reality only. Mark each flow Verified current (with the proof) or Planned.
     Update in the same change as the code. Remove or archive obsolete flows.
     Never write "the system validates X" unless the validation exists in code.
     Every backticked path below must exist: the gate warns when one does not. -->

## <fill: flow name, e.g. POST /api/action>
Status: Planned | Verified current — `<fill: test or command>` <date>

```text
<fill: entry point>
  |-> <fill: path/handler.ext>:<function>()      input validation, error boundary
  |-> <fill: path/service.ext>:<function>()      real computation
  |-> <fill: path/repository.ext>:<function>()   persistence / external call (timeout, cap)
  `-> <fill: real output: status, payload, log line, event>
```

### Failure paths
| Failure | Detected in | User sees | Logged |
|---|---|---|---|
| <fill> | <fill> | <fill> | <fill> |

### Fallback ladder (if any — every rung real, last rung honest failure or human review)
<fill: primary → secondary → honest failure>

### External calls
| Call | Timeout / cap | On failure |
|---|---|---|
| <fill> | <fill> | <fill> |
