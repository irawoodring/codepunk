# The Grand Engine

You've reached the heart of the Foundry: the **Grand Engine**, whose pipes carry steam to every chamber in the city. It has been dark for a hundred years. The **Aether Core** that powers it is locked inside, and the lock is the network itself.

The pipe network is a **graph** stored as a dictionary. Each chamber maps to a list of chambers it's piped to. Pipes go **both ways**, and the dictionary always lists both directions.

```python
network = {
    "boiler":   ["valves", "turbine"],
    "valves":   ["boiler", "press"],
    "turbine":  ["boiler", "press"],
    "press":    ["valves", "turbine", "forge"],
    "forge":    ["press"],
    "lantern":  ["attic"],
    "attic":    ["lantern"],
}
```

## Your Mission

### 1. `reachable(network, start)`

Return a **set** of every chamber steam can reach from `start`, including `start` itself.

```python
reachable(network, "boiler")
# {"boiler", "valves", "turbine", "press", "forge"}
```

### 2. `shortest_route(network, start, goal)`

Return a **list** of chambers along a route from `start` to `goal` that uses the **fewest pipes**, including both ends. If `start == goal`, return `[start]`. If there's no route, return `None`.

```python
shortest_route(network, "boiler", "forge")
# ["boiler", "valves", "press", "forge"]  (or through "turbine": also 3 pipes)
shortest_route(network, "boiler", "attic")  # None
```

### 3. `isolated(network, boiler)`

Return an **alphabetically sorted list** of chambers that steam from `boiler` can **never** reach.

```python
isolated(network, "boiler")  # ["attic", "lantern"]
```

### 4. `pipes_needed(network, start, goal)`

Return the number of pipes on the shortest route, or `-1` if there's no route.

```python
pipes_needed(network, "boiler", "forge")  # 3
```

**Hint:** *Breadth-first search* explores chambers in order of distance from the start, which makes it perfect for shortest routes. `from collections import deque` gives you a fast queue.
