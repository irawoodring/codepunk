# Passenger Manifest

Two airships, the *Sparrow* and the *Kestrel*, are boarding at the same time, and the passenger lists are a muddle. The purser's lockbox opens for anyone who can sort out **who is where**.

Passenger lists are Python lists of names. **Sets** will make this much easier!

## Your Mission

### 1. `unique_passengers(manifests)`

`manifests` is a list of passenger lists. Return how many **different** people are on them altogether.

```python
unique_passengers([["Ada", "Babbage"], ["Babbage", "Lovelace", "Ada"]])   # 3
```

### 2. `on_both(a, b)`

Return an **alphabetically sorted list** of people on both lists.

```python
on_both(["Ada", "Babbage", "Tesla"], ["Tesla", "Ada", "Curie"])   # ["Ada", "Tesla"]
```

### 3. `missing(expected, boarded)`

Return a sorted list of people who were `expected` but haven't `boarded`.

```python
missing(["Ada", "Babbage", "Tesla"], ["Tesla"])   # ["Ada", "Babbage"]
```

### 4. `only_one(a, b)`

Return a sorted list of people on **exactly one** of the two lists.

```python
only_one(["Ada", "Babbage"], ["Babbage", "Curie"])   # ["Ada", "Curie"]
```

### 5. `has_duplicates(names)`

Return `True` if any name appears more than once (someone bought two tickets!).

```python
has_duplicates(["Ada", "Tesla", "Ada"])   # True
```
