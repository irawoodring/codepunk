# Crate Labels

The dock's label printer is broken, and every crate needs a neat label before it can be loaded. The printer's toolbox opens for anyone who can **format strings perfectly**: every space and dot counts!

## Your Mission

### 1. `label(name, weight)`

Make a label that is exactly **23 characters** wide:

* the name in **UPPERCASE**, cut to at most 12 characters, padded on the right with dots (`.`) to exactly 12 characters;
* then the weight, right-aligned in 8 characters, with exactly 2 decimal places;
* then `" kg"`.

```python
label("bearings", 12.5)         # "BEARINGS....   12.50 kg"
label("brass fittings", 1200)   # "BRASS FITTIN 1200.00 kg"
```

### 2. `money(amount)`

Format an amount of money with a dollar sign, commas between thousands, and 2 decimal places. Negative amounts put the minus sign first.

```python
money(1234.5)   # "$1,234.50"
money(7)        # "$7.00"
money(-5)       # "-$5.00"
```

### 3. `manifest(crates)`

`crates` is a list of `(name, weight)` tuples. Return one string with a label for each crate on its own line, then a line of 23 dashes, then a label for the total called `"total"`. Lines are separated by `"\n"` (no newline at the very end).

```python
print(manifest([("tea", 30), ("coal", 120.25)]))
```
```
TEA.........   30.00 kg
COAL........  120.25 kg
-----------------------
TOTAL.......  150.25 kg
```

### 4. `progress_bar(done, total, width=10)`

Draw a loading bar. The number of `#` is `done * width // total`; the rest of the `width` is `-`. After the bar, add a space and the whole-number percentage (`done * 100 // total`). Raise `ValueError` if `total` is 0.

```python
progress_bar(5, 10)       # "[#####-----] 50%"
progress_bar(1, 3, 6)     # "[##----] 33%"
```
