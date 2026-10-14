# Express Loading

The express airship leaves in five minutes, and the loading crew needs answers **fast**. Every function here can be written in **one line** using a *comprehension*. The crew chief's locker opens if you can keep up!

`crates` is a dictionary from crate name to weight in kg:

```python
crates = {"tea": 30, "coal": 1200, "silk": 8, "iron": 950}
```

## Your Mission

### 1. `heavy_names(crates, limit)`

Return a **list** of the names of crates heavier than `limit`, in the dictionary's order.

```python
heavy_names(crates, 100)   # ["coal", "iron"]
```

### 2. `in_tons(crates)`

Return a **new dictionary** with the same names, but weights in tons (kg / 1000), rounded to 3 decimal places.

```python
in_tons(crates)   # {"tea": 0.03, "coal": 1.2, "silk": 0.008, "iron": 0.95}
```

### 3. `flatten(holds)`

`holds` is a list of lists (one list of crate names per cargo hold). Return one flat list of all crate names, in order.

```python
flatten([["tea", "silk"], [], ["coal"]])   # ["tea", "silk", "coal"]
```

### 4. `initials(names)`

Return a **set** of the uppercase first letters of the names. Skip empty strings.

```python
initials(["tea", "Tin", "coal", ""])   # {"T", "C"}
```

### 5. `cargo_grid(rows, cols)`

Return a grid (a list of lists) with `rows` rows and `cols` columns, every spot holding `"."`. Each row must be a **separate** list: changing one row must not change the others!

```python
cargo_grid(2, 3)   # [[".", ".", "."], [".", ".", "."]]
```

**Challenge yourself:** can you write each function body as a single `return` line?
