import inspect
import itertools

import pytest

from mymodule import countdown, running_total, take, every_nth, Orbit


def test_countdown():
    assert list(countdown(3)) == [3, 2, 1]
    assert list(countdown(0)) == []


def test_countdown_is_generator():
    assert inspect.isgenerator(countdown(3)), "countdown should use `yield`"


def test_running_total():
    assert list(running_total([5, 1, 4])) == [5, 6, 10]
    assert list(running_total([])) == []
    assert inspect.isgenerator(running_total([1]))


def test_running_total_is_lazy():
    gen = running_total(itertools.count(1))
    assert [next(gen) for _ in range(4)] == [1, 3, 6, 10]


def test_take():
    assert take(itertools.count(10), 3) == [10, 11, 12]
    assert take("ab", 5) == ["a", "b"]
    assert take([1, 2, 3], 0) == []


def test_take_from_generator():
    assert take(countdown(10), 2) == [10, 9]


def test_every_nth():
    assert list(every_nth("ABCDEFG", 3)) == ["A", "D", "G"]
    assert list(every_nth([1, 2, 3], 1)) == [1, 2, 3]
    assert list(every_nth([], 2)) == []


def test_every_nth_infinite():
    assert take(every_nth(itertools.count(), 5), 3) == [0, 5, 10]


def test_orbit():
    o = Orbit(["Mercury", "Venus"], 2)
    assert list(o) == ["Mercury", "Venus", "Mercury", "Venus"]


def test_orbit_restarts():
    o = Orbit(["Mars"], 3)
    assert list(o) == ["Mars", "Mars", "Mars"]
    assert list(o) == ["Mars", "Mars", "Mars"]


def test_orbit_independent_loops():
    o = Orbit(["A", "B"], 1)
    pairs = [(x, y) for x in o for y in o]
    assert pairs == [("A", "A"), ("A", "B"), ("B", "A"), ("B", "B")]
