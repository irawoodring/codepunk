# Boiler Gauge

The chest is sealed by a **pressure lock**. Its brass plate reads:

> *"Only an engineer who can read a boiler may pass."*

Every boiler in Cogsworth measures pressure in **psi**, but the Guild's new instruments use **bar**. Help the lock read its own gauge.

## Your Mission

### 1. `psi_to_bar(psi)`

Convert a pressure in psi to bar and return it **rounded to 2 decimal places**. One psi is `0.0689476` bar.

```python
psi_to_bar(100)   # 6.89
psi_to_bar(14.7)  # 1.01
psi_to_bar(0)     # 0.0
```

### 2. `boiler_status(psi)`

Return a string describing the boiler:

* `"cold"` if the pressure is below 50
* `"steady"` if it is from 50 up to and including 150
* `"hot"` if it is above 150 but below 200
* `"critical"` if it is 200 or more

```python
boiler_status(20)    # "cold"
boiler_status(150)   # "steady"
boiler_status(199.5) # "hot"
boiler_status(200)   # "critical"
```

### Bad Input

Both functions should `raise ValueError` if `psi` is negative. A boiler can't suck!

**Hint:** Can `boiler_status` use a chain of `if` / `elif` / `else`?
