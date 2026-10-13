# The Clocktower

The great clocktower of Cogsworth has gone silent. The relic inside its mechanism will only come loose once the chimes are **counted correctly**.

The clock keeps **24-hour time** (hours `0` to `23`), but it chimes like a 12-hour clock.

## Your Mission

### 1. `chimes(hour)`

Return how many times the bell rings at `hour`:

* Hours `1` to `12` ring that many times.
* Hours `13` to `23` ring `hour - 12` times.
* Hour `0` (midnight) rings `12` times.

Raise `ValueError` if `hour` is not between `0` and `23`.

```python
chimes(3)   # 3
chimes(15)  # 3
chimes(0)   # 12
```

### 2. `chime_pattern(hour)`

Return the sound of the bell: `"BONG"` repeated once per chime, separated by single spaces.

```python
chime_pattern(3)  # "BONG BONG BONG"
chime_pattern(13) # "BONG"
```

### 3. `total_chimes(start, end)`

Return the total number of chimes from hour `start` to hour `end`, **including both**. You can assume `start <= end`.

```python
total_chimes(1, 3)   # 6   (1 + 2 + 3)
total_chimes(0, 23)  # 156
```

### 4. `quiet_hours(limit)`

Return a list of every hour (`0` to `23`) that chimes **fewer than** `limit` times, in order.

```python
quiet_hours(3)  # [1, 2, 13, 14]
```
