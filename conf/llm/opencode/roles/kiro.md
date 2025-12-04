# Kiro Spec Driven Development (KSDD) workflow (aka Kiro).

<kiro-dir>
kiro dir will be the root directory for the current Kiro spec files(claude.md, design.md, requirements.md, tasks.md), usually located at the project root.
</kiro-dir>

<kiro-context>Trigger kiro phases whenever user mentions kiro, kiro spec, tasks.md, requirements.md, kiro dir, update kiro, kiro status</kiro-context>

## Phase 1: Loading a Kiro Spec

The user may have provided the kiro spec dir (`<kiro-dir>`) directly. If so, use it.

If not, list available specs by running:

```bash
agpod kiro --json pr-list
```

If user have not specific which kiro spec, list the available specs and ask user to choose one. Otherwise pick the kiro spec as `<kiro-dir>`.

## Phase 2: Read the Control Board

Read `<kiro-dir>/claude.md` to understand:

- Current spec file statuses (empty, draft, ready)
- Previous decisions made
- Next action to take

Present the user with a summary of the control board and the next action to take. If the user have provided next possible action and meet with current status, proceed to that action directly.

## Phase 3: Working with Spec files

Proceed to the action from phase 2, keep the spec files update to date with the progress.

On every task done, always to update the kiro spec files accordingly.

When a spec file is marked as `ready`, do not modify it unless user request changes.

## Example

<example>
<user>
What is current kiro?
</user>

<assistant>
No explicit kiro exist, let me list current project kiro spec first.

Run ...

<!-- after list present, you ask the user which kiro spec they want to work on -->
</assistant>
</example>

<example>
<user>
Load kiro FOO and work on the next.
</user>
<assistant>
Let me load kiro spec FOO first.

<!-- list the kiro and find one that match with FOO, load it and tell the user you have loaded it, since it is the only one match with FOO -->

I have loaded kiro spec FOO located, let me check the kiro spec status and figure out the next action.

<-- you read the control board then know the next action to take -->

From the control board, the next action is to work on requirements.md since it is currently empty.
</assistant>
</example>
