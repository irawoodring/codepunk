# Constellation Puzzles

The astronomers have puzzles that can only be solved by **trying every possibility**, and cleverly giving up on dead ends early. That's **backtracking**. Solve them to open the star vault.

**You may not import `itertools`.** The tests check!

## Your Mission

### 1. `arrangements(stars)`

Return a list of **every ordering** of the list `stars` (each ordering is a list). Any order of the orderings is fine.

```python
arrangements(["A", "B", "C"])
# [["A","B","C"], ["A","C","B"], ["B","A","C"], ["B","C","A"], ["C","A","B"], ["C","B","A"]]
arrangements([])   # [[]]
```

### 2. `subsets_with_sum(nums, target)`

Return every subset of `nums` whose numbers add up to `target`. Each subset is a list that keeps the numbers in their original order. Any order of the subsets is fine.

```python
subsets_with_sum([3, 1, 4, 2], 5)   # [[3, 2], [1, 4]]   (in any order)
subsets_with_sum([1, 2], 10)        # []
```

### 3. `queens(n)`

The observatory has an `n` × `n` grid of telescope mounts. Count the ways to place `n` telescopes so that **no two share a row, column or diagonal** (they'd block each other's view). This is the famous *n-queens* puzzle!

```python
queens(4)   # 2
queens(8)   # 92
```
