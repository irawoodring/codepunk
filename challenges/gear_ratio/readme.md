# Gear Ratio

This relic floats inside a cage of interlocking gears. To free it, you must make the gears turn **just right**.

When a **driver** gear (the one the engine turns) meshes with a **driven** gear, how fast the driven gear spins depends on their tooth counts.

## Your Mission

### 1. `ratio(driver_teeth, driven_teeth)`

Return the gear ratio, `driven_teeth / driver_teeth`, **rounded to 2 decimal places**.

```python
ratio(10, 30)  # 3.0
ratio(12, 8)   # 0.67
```

### 2. `output_rpm(input_rpm, driver_teeth, driven_teeth)`

Return how fast the driven gear spins, in revolutions per minute: `input_rpm * driver_teeth / driven_teeth`, **rounded to 1 decimal place**.

```python
output_rpm(300, 10, 30)  # 100.0
output_rpm(90, 12, 8)    # 135.0
```

### 3. `full_turns(degrees)`

A gear has turned some whole number of `degrees`. Return a **tuple** `(turns, leftover)`: the number of complete 360° turns, and the degrees left over.

```python
full_turns(800)  # (2, 80)
full_turns(360)  # (1, 0)
full_turns(45)   # (0, 45)
```

### Bad Input

`ratio` and `output_rpm` should `raise ValueError` if either tooth count is less than 1.

**Hint:** Python's `//` operator does whole-number division, and `%` gives the remainder.
