# Wandering Automaton

A clockwork automaton is wandering the alleys, following punched-card commands. Its master locked a relic away until someone can **predict where it ends up**.

Each command is one letter:

* `N`: north, `y + 1`
* `S`: south, `y - 1`
* `E`: east, `x + 1`
* `W`: west, `x - 1`

## Your Mission

### 1. `final_position(commands)`

The automaton starts at `(0, 0)`. Return its final position as a tuple `(x, y)`. Ignore any letter that isn't `N`, `S`, `E` or `W`.

```python
final_position("NNE")    # (1, 2)
final_position("NESW")   # (0, 0)
final_position("N?N")    # (0, 2)
```

### 2. `steps_until_home(commands)`

Return the number of commands carried out when the automaton **first returns** to `(0, 0)`. Return `-1` if it never comes back.

```python
steps_until_home("NESW")   # 4
steps_until_home("NSNS")   # 2
steps_until_home("NNN")    # -1
```

### 3. `walk_grid(grid, commands)`

Now the automaton walks on a map. `grid` is a list of strings: `"."` is open ground, `"#"` is a wall, and `"A"` is where the automaton starts. **Row 0 is the top**, so `N` moves **up** one row (row - 1) and `E` moves right (col + 1).

If a move would hit a wall or leave the map, the automaton **stays where it is** for that command. Return its final `(row, col)`.

```python
grid = [
    "....",
    ".#..",
    "A...",
]
walk_grid(grid, "NNE")  # (0, 1)
walk_grid(grid, "ENN")  # (2, 1)   blocked by the wall twice
```
