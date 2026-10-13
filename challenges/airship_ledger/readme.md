# Airship Ledger

The fuel depot records every coal delivery as a `(ship, tons)` **tuple**:

```python
records = [("Sparrow", 12), ("Behemoth", 40), ("Sparrow", 8), ("Kestrel", 5)]
```

The quartermaster's strongbox opens only when the ledger is **tallied**.

## Your Mission

### 1. `fuel_by_ship(records)`

Return a **dictionary** mapping each ship's name to the total tons of fuel it received.

```python
fuel_by_ship(records)
# {"Sparrow": 20, "Behemoth": 40, "Kestrel": 5}
```

### 2. `thirstiest(ledger)`

`ledger` is a dictionary like the one above. Return the **name** of the ship that used the most fuel. Return `None` for an empty ledger. (No ties will be tested.)

```python
thirstiest({"Sparrow": 20, "Behemoth": 40, "Kestrel": 5})  # "Behemoth"
```

### 3. `ships_below(ledger, threshold)`

Return an **alphabetically sorted list** of the ships that used **less than** `threshold` tons.

```python
ships_below({"Sparrow": 20, "Behemoth": 40, "Kestrel": 5}, 25)
# ["Kestrel", "Sparrow"]
```

### 4. `refuel(ledger, ship, tons)`

Add `tons` to `ship`'s total **in the ledger itself** (change the dictionary you were given). If the ship isn't in the ledger yet, add it. Return nothing.

```python
ledger = {"Sparrow": 20}
refuel(ledger, "Sparrow", 5)
refuel(ledger, "Zephyr", 3)
ledger  # {"Sparrow": 25, "Zephyr": 3}
```
