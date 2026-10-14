# Star Search

Welcome to the **Celestial Observatory**! The astronomers keep a catalogue of star brightnesses in a **sorted list**. Searching it one star at a time is far too slow: there are millions! The first strongbox opens for anyone who can use **binary search**.

**You may not use `.index()`, the `in` operator on the list, or the `bisect` module.** The tests check!

## Your Mission

All lists here are sorted from smallest to largest.

### 1. `binary_search(stars, target)`

Return the index of `target` in `stars`, or `-1` if it isn't there.

```python
binary_search([2, 5, 8, 12, 16, 23, 38], 23)   # 5
binary_search([2, 5, 8, 12, 16, 23, 38], 7)    # -1
```

### 2. `count_checks(stars, target)`

Return how many times binary search **looks at a middle element** before it finds `target` (or gives up). For a list of 1,000 stars, that should never be more than 10. A linear search could need 1,000!

```python
count_checks([1, 2, 3, 4, 5, 6, 7], 4)   # 1  (the very first middle is 4)
```

### 3. `first_at_least(stars, value)`

Return the index of the first star that is **greater than or equal to** `value`. If every star is smaller, return `len(stars)`. (This tells you where `value` would be inserted to keep the list sorted.)

```python
first_at_least([2, 5, 8, 12], 6)    # 2
first_at_least([2, 5, 8, 12], 5)    # 1
first_at_least([2, 5, 8, 12], 99)   # 4
```

### 4. `count_between(stars, low, high)`

Return how many stars have a brightness from `low` to `high`, inclusive. Use `first_at_least` twice; don't loop over the whole list!

```python
count_between([1, 3, 3, 5, 8, 9], 3, 8)   # 4
```
