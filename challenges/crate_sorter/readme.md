# Crate Sorter

The Foundry's conveyor belts are jammed with crates in no particular order. The sorting engine's strongbox opens only for an engineer who can sort **without help**.

**You may not use `sorted()` or `.sort()` anywhere in your code.** The tests check!

## Your Mission

### 1. `insertion_sort(crates)`

Return a **new** list of the numbers in `crates`, sorted smallest to largest, using **insertion sort**. Don't change the list you were given.

```python
insertion_sort([5, 2, 9, 1])  # [1, 2, 5, 9]
```

### 2. `merge(left, right)`

`left` and `right` are each **already sorted**. Return one sorted list containing everything from both.

```python
merge([1, 4, 9], [2, 3, 10])  # [1, 2, 3, 4, 9, 10]
merge([], [7])                 # [7]
```

### 3. `merge_sort(crates)`

Return a new sorted list using **merge sort**: split the list in half, sort each half (recursively!), then `merge` the halves.

```python
merge_sort([38, 27, 43, 3, 9, 82, 10])  # [3, 9, 10, 27, 38, 43, 82]
```

### 4. `sort_by_weight(crates)`

Now each crate is a tuple `(label, weight)`. Return a new list sorted by **weight**. Crates with the same weight must stay in their **original order** (this is called a *stable* sort; insertion sort and merge sort can both be stable!).

```python
sort_by_weight([("tea", 30), ("coal", 10), ("gin", 30), ("ore", 5)])
# [("ore", 5), ("coal", 10), ("tea", 30), ("gin", 30)]
```
