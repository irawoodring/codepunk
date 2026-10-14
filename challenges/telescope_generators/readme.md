# Telescope Feed

The great telescope streams an endless feed of observations: far too many to store in a list. The lens cabinet opens for anyone who can work with data **one item at a time**, using **generators** and **iterators**.

## Your Mission

### 1. `countdown(n)`

A **generator** that yields `n`, `n - 1`, ... down to `1`.

```python
list(countdown(3))   # [3, 2, 1]
```

### 2. `running_total(numbers)`

A generator that yields the running total after each number.

```python
list(running_total([5, 1, 4]))   # [5, 6, 10]
```

### 3. `take(iterable, n)`

Return a **list** of the first `n` items of any iterable, even an **infinite** one. If it has fewer than `n` items, return them all.

```python
import itertools
take(itertools.count(10), 3)   # [10, 11, 12]
take("ab", 5)                  # ["a", "b"]
```

### 4. `every_nth(iterable, n)`

A generator that yields the 1st item, then every `n`th item after it. It must also work on infinite iterables.

```python
list(every_nth("ABCDEFG", 3))              # ["A", "D", "G"]
take(every_nth(itertools.count(), 5), 3)   # [0, 5, 10]
```

### 5. Class `Orbit(planets, laps)`

An **iterable**: looping over it yields the planets in order, `laps` times. Every new loop must start again from the beginning.

```python
o = Orbit(["Mercury", "Venus"], 2)
list(o)   # ["Mercury", "Venus", "Mercury", "Venus"]
list(o)   # the same again!
```
