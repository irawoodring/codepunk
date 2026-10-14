# The Constellation Tree

The astronomers file every star they discover in a **binary search tree**, ordered alphabetically by name. The archive cabinet opens for anyone who can build one.

## Provided: `StarNode`

```python
class StarNode:
    def __init__(self, name):
        self.name = name
        self.left = None    # names that come BEFORE this one
        self.right = None   # names that come AFTER this one
```

## Your Mission

Write the class `ConstellationTree`. A new tree is empty (`self.root = None`).

### `insert(name)`

Add a star in the right place: alphabetically smaller names go **left**, bigger go **right**. A name that's already in the tree is **not** added again. Return `True` if the star was added, `False` if it was a duplicate.

### `__contains__(name)`

Return `True` if the star is in the tree, so `"Vega" in tree` works. Don't look at every node: follow left or right!

### `__len__()`

Return the number of stars.

### `in_order()`

Return a list of all the names in alphabetical order.

### `height()`

Return the number of nodes on the longest path from the root down to a leaf. An empty tree has height `0`; a single star has height `1`.

### `first()` and `last()`

Return the alphabetically first and last names, or `None` for an empty tree.

```python
t = ConstellationTree()
for star in ["Polaris", "Altair", "Vega", "Betelgeuse"]:
    t.insert(star)
t.insert("Vega")        # False
"Altair" in t           # True
len(t)                  # 4
t.in_order()            # ["Altair", "Betelgeuse", "Polaris", "Vega"]
t.height()              # 3   (Polaris -> Altair -> Betelgeuse)
t.first(), t.last()     # ("Altair", "Vega")
```
