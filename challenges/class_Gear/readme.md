# The Gear Class

Welcome to the **Aetherforge Foundry**. Here engineers don't just *use* gears, they **design** them. The first strongbox wants you to model one as a class.

## Your Mission

Write a class `Gear`.

### Constructor: `Gear(teeth, material="brass")`

* Store the values in the attributes `teeth` and `material`.
* A gear needs at least 6 teeth. If `teeth < 6`, `raise ValueError`.

```python
g = Gear(12)
g.teeth     # 12
g.material  # "brass"
Gear(30, "steel").material  # "steel"
```

### `__repr__(self)`

Return a string that looks like the code to build the gear:

```python
repr(Gear(12))           # "Gear(12, 'brass')"
repr(Gear(40, "steel"))  # "Gear(40, 'steel')"
```

### `__eq__(self, other)` and `__lt__(self, other)`

Two gears are **equal** if they have the same number of teeth **and** the same material. One gear is **less than** another if it has fewer teeth. Once `__lt__` works, `sorted()` can sort a list of gears!

```python
Gear(12) == Gear(12)            # True
Gear(12) == Gear(12, "steel")   # False
Gear(10) < Gear(20)             # True
```

### `mesh_ratio(self, other)`

Return how many times *this* gear turns for one turn of `other`: `other.teeth / self.teeth`, rounded to 2 decimal places.

```python
Gear(10).mesh_ratio(Gear(30))  # 3.0
```

### `is_compatible(self, other)`

Gears made of different materials grind each other to dust. Return `True` only if both gears share a material.
