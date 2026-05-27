# Composite Controls

This note records a future design direction discovered while prototyping the `data3` / `ui3` / `logic3` Biome Control rewrite.

## Problem

Control-heavy immediate-mode UI has three related needs:

- Storage needs stable declarations.
- UI needs repeated draw patterns.
- Runtime logic needs semantic read helpers.

The current prototype uses controller objects as the shared representation for all three. That works, but it also means controller objects are threaded through storage building, UI drawing, runtime logic, hash groups, and tests.

## Direction

For future module design, repeated controls can be modeled as small domain composites:

```text
control template
  -> owns storage/data bindings
  -> owns draw behavior
  -> owns runtime read semantics
```

Example concepts:

- `modeRange`
- `npcModeRange`
- `packedRewardBans`
- `dreamRoute`

The module declaration should provide minimal domain information:

```lua
room.story("Arachne", {
    min = 4,
    max = 8,
})
```

The template can derive storage aliases, draw behavior, and runtime readers from that domain declaration.

## Alias Policy

Generated aliases should not collide with hand-authored storage aliases.

Potential future rule:

```text
Public storage aliases: start alphanumeric.
Generated/internal aliases: start with "_".
```

If generated aliases are internal, raw `state.get("_...")` / `store.read("_...")` access should eventually be blocked for author code. Authors should use the owning composite/control object instead.

That allows templates to change their internal storage layout later without breaking callers.

## State And Store

`state` and `store` should remain the canonical phase-specific data access objects.

Composites should sit above them:

```text
state/store = phase-specific data access
control = semantic interface over one or more data bindings
draw = immediate-mode rendering operations
```

This avoids making composites the storage authority while still letting controls hide internal implementation details.

## Nested Composites

Nested composites are useful for grouping and layout, but should stay shallow.

Preferred rule:

```text
Leaf composites own data bindings.
Parent composites organize leaves.
```

Good:

```text
Biome section
  contains room controls
  contains miniboss controls
```

Risky:

```text
Composite A owns storage
  contains Composite B owns storage
    contains Composite C owns storage
```

Storage derivation, hashing, reset, validation, UI, and runtime reads should flatten leaf controls rather than recursively treating every parent as a storage owner.

## Release Position

This is not part of the 2.1 capability upgrade.

For 2.1, keep the public module API stable and continue exposing `state`, `store`, `draw`, and widgets as the canonical author-facing surface.

Composite controls should remain a future module-local pattern until more modules prove the shape.
