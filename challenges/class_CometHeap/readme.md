# Comet Heap

Comets are streaking toward the Observatory, and the telescope must always point at the **closest** one next. A plain list would need sorting every time a new comet appears. Instead, you'll build a **min-heap**.

**You may not import `heapq`.** The tests check!

## How a min-heap works

The heap lives in a Python list, `self.items`. For the item at index `i`:

* its **parent** is at index `(i - 1) // 2`
* its **children** are at `2 * i + 1` and `2 * i + 2`

The rule: **every parent is less than or equal to its children**, so the smallest item is always `items[0]`.

## Your Mission

### Class `MinHeap`

* `MinHeap()`: starts empty (`self.items = []`).
* `push(x)`: add `x`, keeping the heap rule.
* `peek()`: return the smallest item without removing it. Raise `IndexError` if empty.
* `pop()`: remove and return the smallest item, keeping the heap rule. Raise `IndexError` if empty.
* `__len__()`: the number of items.

```python
h = MinHeap()
for d in [42, 7, 19, 3]:
    h.push(d)
h.peek()   # 3
h.pop()    # 3
h.pop()    # 7
len(h)     # 2
```

### Function `closest_comets(distances, k)`

Use your `MinHeap` to return the `k` smallest distances, smallest first. If there are fewer than `k`, return them all.

```python
closest_comets([42, 7, 19, 3, 88], 3)   # [3, 7, 19]
```
