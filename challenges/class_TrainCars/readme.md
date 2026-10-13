# The Rail Yard

Freight trains rumble through the Foundry's rail yard. Each train is a chain of **cars**, and each car only knows which car is coupled **behind** it. That's a **linked list**!

The yardmaster's lockbox opens for anyone who can manage the trains.

## Provided: `Car`

```python
class Car:
    def __init__(self, cargo):
        self.cargo = cargo
        self.next = None   # the car behind this one
```

## Your Mission

Write the class `Train`. A new train is empty (`self.head = None`). **Don't use a Python list to store the cars:** link `Car` objects together.

### `attach(cargo)`

Couple a new car with this `cargo` to the **back** of the train.

### `couple_front(cargo)`

Couple a new car with this `cargo` to the **front** of the train.

### `__len__()`

Return the number of cars, so `len(train)` works.

### `to_list()`

Return a Python list of the cargo, front to back.

```python
t = Train()
t.attach("coal")
t.attach("tea")
t.couple_front("engine")
t.to_list()  # ["engine", "coal", "tea"]
len(t)       # 3
```

### `detach(cargo)`

Remove the **first** car carrying `cargo`. Return `True` if a car was removed, or `False` if no car had that cargo.

```python
t.detach("coal")    # True
t.to_list()         # ["engine", "tea"]
t.detach("gold")    # False
```

### `reverse()`

Turn the train around **in place**, so the last car becomes the head. Don't create new cars: re-link the existing ones.

```python
t.reverse()
t.to_list()  # ["tea", "engine"]
```
