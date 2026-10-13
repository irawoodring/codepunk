# Gears Within Gears

The relic in this chamber sits at the heart of a machine of gears inside gears inside gears. The only way in is to think **recursively**.

**Every function here must call itself.** The tests check!

## Your Mission

### 1. `spin(n)`

Gears in a chain alternate direction. Gear 1 spins `"clockwise"`, gear 2 spins `"counterclockwise"`, gear 3 spins `"clockwise"`, and so on. Return the direction of gear `n` (where `n >= 1`).

Think recursively: gear `n` spins the **opposite** way to gear `n - 1`.

```python
spin(1)  # "clockwise"
spin(4)  # "counterclockwise"
```

### 2. `train_ratio(teeth)`

`teeth` is a list of tooth counts for gears meshed one after another. The ratio of the whole train is the **product** of each neighbouring pair's ratio `next / current`... which simplifies to `last / first`! But do it recursively: the ratio of `[a, b, c, ...]` is `(b / a)` times the ratio of `[b, c, ...]`. A train with a single gear has ratio `1.0`.

```python
train_ratio([10, 20, 40])  # 4.0
train_ratio([12])          # 1.0
```

### 3. `count_cogs(blueprint)`

A blueprint is a list that can contain numbers (cogs) **and other lists** (sub-assemblies), nested to any depth. Return the total number of cogs.

```python
count_cogs([1, 2, [3, 4, [5]], 6])  # 6
count_cogs([[], [[]]])               # 0
```

### 4. `blueprint_depth(blueprint)`

Return how deeply the blueprint is nested. A flat list (even an empty one) has depth 1.

```python
blueprint_depth([1, 2, 3])            # 1
blueprint_depth([1, [2, [3]], [4]])   # 3
```
