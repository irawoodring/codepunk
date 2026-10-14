import ast
import inspect

import pytest

import mymodule
from mymodule import arrangements, subsets_with_sum, queens


def normalise(lists):
    return sorted(tuple(x) for x in lists)


def test_no_itertools():
    tree = ast.parse(inspect.getsource(mymodule))
    for node in ast.walk(tree):
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            names = [a.name for a in node.names] + [getattr(node, "module", None) or ""]
            if any("itertools" in n for n in names):
                pytest.fail("itertools isn't allowed: do the backtracking yourself!")


def test_arrangements_three():
    result = arrangements(["A", "B", "C"])
    assert normalise(result) == [("A", "B", "C"), ("A", "C", "B"), ("B", "A", "C"),
                                 ("B", "C", "A"), ("C", "A", "B"), ("C", "B", "A")]


def test_arrangements_small():
    assert arrangements([]) == [[]]
    assert arrangements(["Vega"]) == [["Vega"]]


def test_arrangements_count():
    result = arrangements([1, 2, 3, 4, 5])
    assert len(result) == 120
    assert len(set(map(tuple, result))) == 120


def test_arrangements_does_not_change_input():
    stars = ["A", "B"]
    arrangements(stars)
    assert stars == ["A", "B"]


def test_subsets_with_sum():
    assert normalise(subsets_with_sum([3, 1, 4, 2], 5)) == [(1, 4), (3, 2)]
    assert subsets_with_sum([1, 2], 10) == []


def test_subsets_with_sum_includes_empty_for_zero():
    assert normalise(subsets_with_sum([1, 2], 0)) == [()]


def test_subsets_with_sum_more():
    result = subsets_with_sum([1, 2, 3, 4, 5, 6], 6)
    assert normalise(result) == [(1, 2, 3), (1, 5), (2, 4), (6,)]


@pytest.mark.parametrize("n, expected", [(1, 1), (2, 0), (3, 0), (4, 2), (5, 10), (6, 4), (8, 92)])
def test_queens(n, expected):
    assert queens(n) == expected
