# Orbital Calculations

The Observatory's calculating engine works out orbits by solving the same small sums over and over. It's so slow the comets have left before it finishes! The engine room opens for anyone who can **remember answers instead of recomputing them**.

The tests use big inputs. Simple recursion would take years, so you'll need **memoization** or **dynamic programming**. (The whole run is stopped after 10 seconds.)

## Your Mission

### 1. `orbit_paths(n)`

A probe climbs `n` orbital rings, jumping **1 or 2 rings** at a time. How many different jump sequences reach ring `n` exactly? (`orbit_paths(0)` is `1`: do nothing.)

```python
orbit_paths(3)    # 3   (1+1+1, 1+2, 2+1)
orbit_paths(10)   # 89
orbit_paths(80)   # 37889062373143906  (must be fast!)
```

### 2. `fewest_lenses(focus, lenses)`

A telescope needs lenses whose strengths add up to exactly `focus`. `lenses` lists the strengths available (you can use each as many times as you like). Return the **fewest** lenses needed, or `-1` if it's impossible.

```python
fewest_lenses(11, [1, 2, 5])            # 3   (5 + 5 + 1)
fewest_lenses(63, [1, 5, 10, 21, 25])   # 3   (21 + 21 + 21; "biggest first" gets this wrong!)
fewest_lenses(3, [2])                   # -1
fewest_lenses(0, [1, 2])                # 0
```

### 3. `longest_shared_signal(a, b)`

Two observatories recorded radio signals as strings. Return the length of the longest sequence of characters that appears in **both**, in the same order (not necessarily next to each other).

```python
longest_shared_signal("ABCBDAB", "BDCABA")   # 4  (e.g. "BCBA")
longest_shared_signal("STEAMPUNK", "SPANNER") # 3  (e.g. "SPN")
```
