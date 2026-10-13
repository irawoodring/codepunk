# Pipe Balancer

The Foundry's pipe-fitters write their plans in shorthand. Each **fitting** is a bracket: `(`, `[`, `{` or `<` opens a section of pipe and `)`, `]`, `}` or `>` closes it. Anything else (letters, numbers, `-`) is just straight pipe.

```
"(--[==]--{<>})"   sealed: every opener is closed by the right partner, in the right order
"(--[==)--]"       leaking: ")" tries to close a "["
```

The steam won't flow (and the relic stays caged) until you can find the **leaks**.

## Your Mission

### 1. `is_sealed(pipes)`

Return `True` if every opening fitting is closed by its matching partner, in the correct (nested) order. Otherwise return `False`.

```python
is_sealed("(--[==]--{<>})")  # True
is_sealed("(--[==)--]")      # False
is_sealed("((")              # False
is_sealed("pipe")            # True  (no fittings at all)
```

### 2. `first_leak(pipes)`

Return the **index** of the first character where the plan goes wrong, or `-1` if it's sealed:

* a closer with no matching opener before it, or that closes the wrong type, leaks **at the closer**;
* if the plan ends with openers still unclosed, the leak is at the **earliest** unclosed opener.

```python
first_leak("(--[==)--]")  # 6
first_leak("]")           # 0
first_leak("a(b[c]d")     # 1
first_leak("{<>}")        # -1
```

### 3. `max_depth(pipes)`

Return the deepest level of nesting in a **sealed** plan. Raise `ValueError` if the plan isn't sealed.

```python
max_depth("(--[==]--{<>})")  # 3
max_depth("--")              # 0
```

**Hint:** a *stack* is perfect for this. When you see an opener, push it. When you see a closer, the top of the stack must be its partner.
