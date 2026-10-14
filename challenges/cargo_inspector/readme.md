# Cargo Inspector

Welcome to the **Skyport Docks**, where airships moor in the clouds! The cargo labels here are written by hand, and some of them are... creative. The inspector's strongbox opens for anyone who can handle bad data **without crashing**.

## Your Mission

### 1. `parse_weight(text)`

Turn a label like `"12.5kg"`, `"12.5 kg"` or `"12.5"` into the number `12.5` (a float). Ignore spaces at the start and end.

If the label isn't a valid weight, **raise a `ValueError`**. Negative weights are also invalid.

```python
parse_weight("12.5kg")   # 12.5
parse_weight(" 40 kg ")  # 40.0
parse_weight("7")        # 7.0
parse_weight("heavy")    # raises ValueError
parse_weight("-3kg")     # raises ValueError
```

**Hint:** `float("heavy")` raises a `ValueError` all by itself!

### 2. `total_weight(labels)`

Add up all the labels that make sense, and count the ones that don't. Return a tuple `(total, bad_count)`, with the total rounded to 2 decimal places. **Don't crash** on bad labels: catch the error.

```python
total_weight(["10kg", "oops", "2.5 kg", "", "-1"])   # (12.5, 3)
```

### 3. `lookup_berth(berths, ship)`

`berths` is a dictionary from ship name to berth number. Return the ship's berth, or the string `"UNASSIGNED"` if the ship isn't in the dictionary. Use `try` / `except KeyError`.

```python
lookup_berth({"Sparrow": 4}, "Sparrow")   # 4
lookup_berth({"Sparrow": 4}, "Kestrel")   # "UNASSIGNED"
```

### 4. `split_load(total, holds)`

Return how much cargo goes in each hold: `total / holds`, rounded to 2 decimal places. If `holds` is `0`, return `None` instead of crashing.

```python
split_load(100, 3)   # 33.33
split_load(100, 0)   # None
```
