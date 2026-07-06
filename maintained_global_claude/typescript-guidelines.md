# TypeScript guidelines

General conventions for writing TypeScript. Several entries call out pitfalls that AI commonly falls into — avoid them. Always defer to an individual repo's own conventions where they differ.

## Types — don't manufacture redundant ones

- **AI loves narrowing a big class into a small partial interface/type for "just the few methods I use." Don't.** Pass the concrete underlying class as the type instead — less indirection, no duplicated types.
- Don't `Pick<>` a class/service's type to pass "just part" of it — pass the whole thing.
- Don't create an `abstract`/interface duplicate of a class definition. A separate type is justified **only when there are 2+ implementations**; with one impl, the class *is* the type.
- Don't infer types (`ReturnType<typeof x>`, etc.) when the underlying type already exists — pass the underlying type.

## Services & layering

- Business logic lives in a dedicated **class-based service** in the domain/service layer — not in transport/edge code (HTTP handlers, queue consumers, controllers). Keep those layers thin.
- **Never fake a service with a factory function that returns an object of functions.** Add a method to a real class-based service (and check whether an existing service can host it before making a new one).
- Before adding a service, check whether existing code already does the read/operation.

## Wiring & dependencies

- Keep edge handlers (consumers, controllers, route handlers) **flat and explicit** — write each one out rather than routing through a generic helper that takes a `handle` callback. Prefer `serviceName.doSomething()` over passing `config.handle`; clearer for humans and AI.
- **No optional dependencies.** Always require the dependency and gate behavior with an explicit boolean param (`shouldPublishX`) — an omitted dep silently skips logic.

## Config & env

- Read `process.env` **only in dedicated config files/modules**, and parse/validate it (e.g. with a schema) at that boundary.
- **AI loves inventing default values for env vars — never do this.** Make the var required and define it in your secrets manager. Avoid default values generally unless there's a real single-source-of-truth reason.
- Config values that rarely change: a `const` at the top of the file that uses them (or a shared config/constants module if multiple places need them), not env.

## Errors & validation — fail loud

- No silent `try/catch` fallbacks on error cases. Parse strictly (not safe-parse-with-fallback) and let errors bubble so we can detect them.
- Validate untrusted input at the **trust boundary** (e.g. the HTTP route); internally trust the typed payload rather than re-validating downstream.

## Async & DB

- **No `for`-loops with `await` inside** — use parallel execution (`Promise.all`, or a concurrency-limited map helper).
- Filter at the **DB query level**, not in app code after fetching.

## Tests

- **AI loves asserting on a handful of individual fields. Prefer `toEqual` on the whole object** — partial assertions miss regressions in fields you forgot. (Single-field checks are fine only when you genuinely care about just that field; then you also don't need `expect(x).toBeUndefined()` noise.)

## Organization

- Don't extract a single-use helper method that doesn't improve readability — inline it. Split out only when the caller is already complex or the logic is reused.
- API input schemas and reused auth/validation belong in their own dedicated modules, **not inline in the route handler**. AI loves inlining these; pull them out once they repeat.

## Migrations

- Generate migrations with your ORM/migration tool's generate command (so it writes the schema snapshot) — never hand-write migration SQL. Squash to a single migration per change.
