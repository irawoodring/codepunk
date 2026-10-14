import ast
import inspect
import random

import pytest

import mymodule
from mymodule import MinHeap, closest_comets


def is_heap(items):
    return all(items[(i - 1) // 2] <= items[i] for i in range(1, len(items)))


def test_no_heapq():
    tree = ast.parse(inspect.getsource(mymodule))
    for node in ast.walk(tree):
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            names = [a.name for a in node.names] + [getattr(node, "module", None) or ""]
            if any("heapq" in n for n in names):
                pytest.fail("heapq isn't allowed: build the heap yourself!")


def test_empty():
    h = MinHeap()
    assert len(h) == 0
    with pytest.raises(IndexError):
        h.peek()
    with pytest.raises(IndexError):
        h.pop()


def test_push_and_peek():
    h = MinHeap()
    for d in [42, 7, 19, 3]:
        h.push(d)
    assert h.peek() == 3
    assert len(h) == 4


def test_pop_order():
    h = MinHeap()
    for d in [42, 7, 19, 3]:
        h.push(d)
    assert [h.pop() for _ in range(4)] == [3, 7, 19, 42]
    assert len(h) == 0


def test_heap_rule_kept_after_pushes():
    h = MinHeap()
    rng = random.Random(1)
    for _ in range(50):
        h.push(rng.randint(0, 100))
        assert is_heap(h.items), "The heap rule is broken after a push: %r" % h.items


def test_heap_rule_kept_after_pops():
    h = MinHeap()
    rng = random.Random(2)
    for _ in range(50):
        h.push(rng.randint(0, 100))
    for _ in range(25):
        h.pop()
        assert is_heap(h.items), "The heap rule is broken after a pop: %r" % h.items


def test_heapsort_random():
    rng = random.Random(3)
    values = [rng.randint(-1000, 1000) for _ in range(300)]
    h = MinHeap()
    for v in values:
        h.push(v)
    out = [h.pop() for _ in range(len(values))]
    expected = list(values)
    expected.sort()
    assert out == expected


def test_closest_comets():
    assert closest_comets([42, 7, 19, 3, 88], 3) == [3, 7, 19]
    assert closest_comets([5, 1], 10) == [1, 5]
    assert closest_comets([], 2) == []
