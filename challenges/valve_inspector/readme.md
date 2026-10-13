# Valve Inspector

A long row of steam valves runs along the canal wall. The inspector left a report, but the chest with their tools only opens once the report is **checked**.

A row of valves is written as a string. `"O"` is an **open** valve and `"X"` is a **closed** one:

```
"OOXOXXXO"
```

## Your Mission

### 1. `count_open(valves)`

Return how many valves are open.

```python
count_open("OOXOXXXO")  # 4
count_open("XXX")       # 0
```

### 2. `longest_closed_run(valves)`

Return the length of the longest stretch of closed valves **next to each other**.

```python
longest_closed_run("OOXOXXXO")  # 3
longest_closed_run("OOO")       # 0
```

### 3. `toggle(valves)`

Return a new string where every open valve is closed and every closed valve is opened.

```python
toggle("OOXOX")  # "XXOXO"
```

### 4. `first_closed(valves)`

Return the **index** of the first closed valve, or `-1` if every valve is open.

```python
first_closed("OOXOX")  # 2
first_closed("OO")     # -1
```

**Challenge yourself:** solve these with loops instead of string methods like `.count()`.
