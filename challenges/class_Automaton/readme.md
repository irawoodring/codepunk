# Automaton Workshop

The Foundry's workshop builds three kinds of clockwork helpers. They share most of their machinery, which makes them perfect for **inheritance**.

## Your Mission

### `Automaton(name, steam=100)`

The base class.

* Attributes: `name` and `steam` (how much fuel is in the tank).
* A plain automaton burns **10 steam per hour** of work.
* `work(hours)`: burn `hours * 10` steam. If there isn't enough steam, `raise RuntimeError` and **don't change** `steam`.
* `refuel(amount)`: add steam, but the tank can never go above `100`.
* `describe()`: return a string like `"Tock the Automaton (40 steam)"`. Subclasses should say their own class name: `"Sparky the WelderBot (100 steam)"`.

```python
a = Automaton("Tock")
a.work(6)
a.steam       # 40
a.describe()  # "Tock the Automaton (40 steam)"
a.refuel(500)
a.steam       # 100
```

### `WelderBot(Automaton)`

* Burns **15 steam per hour** instead of 10.
* Has a `welds` attribute that starts at `0`.
* `weld()`: costs 5 steam (raise `RuntimeError` if there isn't enough) and adds 1 to `welds`.

### `CourierBot(Automaton)`

* Burns **5 steam per hour**.
* Has a `parcels` list that starts empty.
* `deliver(parcel)`: add `parcel` to the end of `parcels` and burn 2 steam (raise `RuntimeError` if there isn't enough).

### `total_steam(bots)` (a function, not a method)

Given a list of any mix of automatons, return the total steam in all of them.

**Think about it:** if `work()` uses an attribute for the burn rate, how much code does each subclass need?
