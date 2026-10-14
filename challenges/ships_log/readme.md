# The Ship's Log

Every airship that docks here records its comings and goings in a **log file**. The harbourmaster's chest opens only for someone who can keep the log straight.

Each entry is one line of text, like:

```
DEPART Sparrow 09:00
ARRIVE Behemoth 09:45
DEPART Kestrel 10:15
```

## Your Mission

`path` is the name of a file, like `"log.txt"`.

### 1. `write_log(path, entries)`

Write each string in the list `entries` to the file, **one per line**. If the file already exists, replace what was in it.

### 2. `read_log(path)`

Return a list of the lines in the file, **without** the newline characters at the end. If the file doesn't exist, return an empty list instead of crashing.

```python
write_log("log.txt", ["DEPART Sparrow 09:00", "ARRIVE Behemoth 09:45"])
read_log("log.txt")      # ["DEPART Sparrow 09:00", "ARRIVE Behemoth 09:45"]
read_log("nothing.txt")  # []
```

### 3. `append_entry(path, entry)`

Add one entry to the **end** of the log, keeping everything already there. (It should also work if the file doesn't exist yet.)

### 4. `count_events(path, event)`

Return how many lines in the log have `event` (like `"DEPART"`) as their **first word**. A line starting `"DEPARTED"` doesn't count as a `"DEPART"`.

```python
count_events("log.txt", "DEPART")   # 1
```

**Hint:** use `with open(path, "w") as f:` so the file is closed for you.
