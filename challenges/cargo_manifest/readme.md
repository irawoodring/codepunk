# Cargo Manifest

The airship *Gilded Sparrow* is loading cargo at the Cogsworth docks. The dockmaster's chest opens only when the manifest **adds up**.

Each crate's weight (in kilograms) is stored in a **list**:

```python
crates = [120, 45, 300, 80, 210]
```

## Your Mission

### 1. `total_weight(crates)`

Return the total weight of all crates (`0` for an empty list).

```python
total_weight([120, 45, 300, 80, 210])  # 755
```

### 2. `heaviest(crates)`

Return the weight of the heaviest crate. Return `None` if there are no crates.

```python
heaviest([120, 45, 300, 80, 210])  # 300
heaviest([])                        # None
```

### 3. `overweight(crates, limit)`

Return a **new list** of the crates that weigh **more than** `limit`, in their original order.

```python
overweight([120, 45, 300, 80, 210], 100)  # [120, 300, 210]
```

### 4. `load_airship(crates, capacity)`

Crates are loaded **in order**. Loading stops at the first crate that would push the total over `capacity`. Return **how many** crates make it on board.

```python
load_airship([120, 45, 300, 80, 210], 500)  # 3   (120 + 45 + 300 = 465)
load_airship([600, 10], 500)                # 0
```

**Challenge yourself:** try writing these without `sum()` or `max()`.
