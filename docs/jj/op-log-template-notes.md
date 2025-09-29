# JJ Operation Log Template Notes

## Goal

Document the troubleshooting process for filtering `jj operation log` entries to
highlight invocations of `jj new`, including the final template expression that
yielded the desired output.

## Context

- Repository: `dots`
- Working directory: `/Users/towry/.dotfiles`
- Command family: `jj operation log`

## Steps Performed

1. Consulted the official template reference at
   <https://jj-vcs.github.io/jj/latest/templates/> to confirm available keywords
   and methods for operation objects.
2. Ran an initial probe command
   `jj operation log --ignore-working-copy --no-graph --no-pager -n 1 -T "self.description() ++ '\\n'"`
   to confirm that `self.description()` returns the human-readable summary.
3. Attempted to filter using `description()` without the `self` prefix, which
   produced `Function description doesn't exist`—confirming that methods must be
   accessed through the `self` keyword in operation templates.
4. Verified that `self.tags()` exposes the `args:` metadata by running
   `jj operation log --ignore-working-copy --no-graph --no-pager -n 1 -T "self.tags() ++ '\\n'"`.
5. Constructed a conditional template to emit only operations whose tags mention
   `jj new`, and iterated on the range (`-n 30`, then `-n 200`) until matches
   were found.

## Commands Executed

```fish
jj operation log --ignore-working-copy --no-graph --no-pager -n 30 -T "if(self.tags().contains(\"jj new\"), separate(\" | \", self.time().start().format(\"%Y-%m-%d %H:%M:%S\"), self.id().short(), self.description(), self.tags()) ++ \"\\n\", \"\")"
jj operation log --ignore-working-copy --no-graph --no-pager -n 200 -T "if(self.tags().contains(\"jj new\"), separate(\" | \", self.time().start().format(\"%Y-%m-%d %H:%M:%S\"), self.id().short(), self.description(), self.tags()) ++ \"\\n\", \"\")"
```

## Template Used

```text
if(self.tags().contains("jj new"), separate(" | ", self.time().start().format("%Y-%m-%d %H:%M:%S"), self.id().short(), self.description(), self.tags()) ++ "\n", "")
```

- `self.tags()` exposes the recorded CLI arguments (e.g., `args: jj new lv`).
- `self.time().start().format("%Y-%m-%d %H:%M:%S")` produces a readable
  timestamp for when the operation began.
- `self.id().short()` shortens the operation ID for compact display.
- `separate(" | ", ...)` joins the fields with a consistent delimiter, and the
  trailing `"\n"` ensures newline-terminated records.

## Findings

1. No `jj new` invocations exist within the most recent 30 operations; widening
   the window to 200 revealed two matches.
2. Matching operations:
   - `2025-09-28 17:11:49 | b67ab055090e | new empty commit | args: jj new lv`
   - `2025-09-27 14:26:13 | 6132a881a177 | new empty commit | args: jj new main`
3. The failure when omitting `self.` helped confirm that operation template
   methods must be accessed via `self`.

## Follow-ups

- Consider saving this template under a reusable alias in `jj.nix` if filtering
  by command type becomes a recurring task.
- Extend the template to match other sub-commands by adjusting the `contains`
  predicate or replacing it with a pattern match.
