# Airship Seating

The grand airship *Albatross* is boarding, and the seating chart is a **2D list**: a list of rows, where each row is a list of seats. `"."` is a free seat and `"X"` is taken.

```python
seats = [
    [".", "X", "."],
    ["X", "X", "X"],
    [".", ".", "X"],
]
```

`seats[2][0]` is row 2, column 0 (free). The steward's cabinet opens for anyone who can manage the seats.

## Your Mission

### 1. `count_free(seats)`

Return the number of free seats.

```python
count_free(seats)   # 4
```

### 2. `first_free(seats)`

Return the `(row, col)` of the first free seat, searching row 0 left to right, then row 1, and so on. Return `None` if the airship is full.

```python
first_free(seats)   # (0, 0)
```

### 3. `book(seats, row, col)`

Book a seat: if `(row, col)` is on the chart (no negative numbers!) **and** free, change it to `"X"` **in the list you were given** and return `True`. Otherwise (taken, or off the chart) change nothing and return `False`.

```python
book(seats, 0, 0)   # True  (now seats[0][0] == "X")
book(seats, 0, 0)   # False (already taken)
book(seats, 9, 9)   # False (no such seat)
```

### 4. `best_row(seats)`

Return the index of the row with the most free seats. If rows tie, return the first. Return `None` if there are no rows.

### 5. `free_pairs(seats)`

Friends want to sit together. Count the places where two free seats are **side by side in the same row**. Overlapping pairs count: `[".", ".", "."]` has 2 pairs.

```python
free_pairs([[".", ".", "."], [".", "X", "."]])   # 2
```
