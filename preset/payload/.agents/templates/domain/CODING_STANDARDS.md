# Coding Standards

> Enforced deterministically via compiler/linter rules wherever possible, and audited by `/code-review` on every PR.

## 1. TypeScript & Type Safety
- **Zero `any` Types:** Every `any` in TypeScript is a leak in the agent's feedback loop. Use `unknown` with type narrowing or explicit domain types.
- **Strict Compiler Flags:** Keep `strict: true`, `noUncheckedIndexedAccess: true`, and `exactOptionalPropertyTypes: true` enabled.
- **Narrow Function Signatures:** Pass only the narrow dependencies a function actually needs—never pass an entire application container or `ManagedRuntime` when a single capability/client suffices.

## 2. Error Handling & Explicit Channels
- **Typed Domain Errors:** Fail with explicit, tagged/discriminated domain errors rather than untyped `throw new Error("...")` strings.
- **Boundary Isolation:** Internal effect/framework primitives must not leak across public module interfaces.

## 3. Configuration & Startup Validation
- **Fail Fast at Startup:** Validate and parse every required environment variable at process startup using a typed config schema (e.g., Zod or Effect `Config`). Never read `process.env.*` lazily deep inside business logic.

## 4. Module Design & Testing (Deep Modules + Seams)
- **Deep Modules:** Prefer fewer, deeper modules with narrow public interfaces over many shallow wrapper files.
- **Test External Behavior at Seams:** Write unit/integration tests against the highest clean public seam of a module. Never couple tests to private helper functions or internal constants.

## 5. Production Security Invariants
- **Authorization at Every Mutation:** Enforce server-side ownership/role checks inside every data mutation; never rely on UI hiding.
- **Parameterized Data Access:** Use parameterized queries/ORM builders exclusively; zero raw string concatenation in queries.
- **No Secrets in Code or Logs:** Never commit `.env` files, tokens, or credentials, and redact sensitive fields from structured logs.
