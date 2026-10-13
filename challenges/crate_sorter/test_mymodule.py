import ast
import inspect
import random

import pytest

import mymodule
from mymodule import insertion_sort, merge, merge_sort, sort_by_weight


def test_no_builtin_sorting():
    tree = ast.parse(inspect.getsource(mymodule))
    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and node.id == "sorted":
            pytest.fail("sorted() isn't allowed; write the algorithm yourself!")
        if isinstance(node, ast.Attribute) and node.attr == "sort":
            pytest.fail(".sort() isn't allowed; write the algorithm yourself!")


def test_insertion_sort():
    assert insertion_sort([5, 2, 9, 1]) == [1, 2, 5, 9]
    assert insertion_sort([]) == []
    assert insertion_sort([3, 3, -1]) == [-1, 3, 3]


def test_insertion_sort_returns_new_list():
    crates = [3, 1, 2]
    result = insertion_sort(crates)
    assert crates == [3, 1, 2]
    assert result is not crates


def test_merge():
    assert merge([1, 4, 9], [2, 3, 10]) == [1, 2, 3, 4, 9, 10]
    assert merge([], [7]) == [7]
    assert merge([1, 2], []) == [1, 2]
    assert merge([2, 2], [2]) == [2, 2, 2]


def test_merge_sort():
    assert merge_sort([38, 27, 43, 3, 9, 82, 10]) == [3, 9, 10, 27, 38, 43, 82]
    assert merge_sort([]) == []
    assert merge_sort([1]) == [1]


def test_merge_sort_does_not_change_original():
    crates = [3, 1, 2]
    merge_sort(crates)
    assert crates == [3, 1, 2]


@pytest.mark.parametrize("seed", [1, 2, 3])
def test_random_lists(seed):
    rng = random.Random(seed)
    crates = [rng.randint(-50, 50) for _ in range(40)]
    expected = list(crates)
    expected.sort()
    assert insertion_sort(crates) == expected
    assert merge_sort(crates) == expected


def test_sort_by_weight_is_stable():
    crates = [("tea", 30), ("coal", 10), ("gin", 30), ("ore", 5)]
    assert sort_by_weight(crates) == [("ore", 5), ("coal", 10), ("tea", 30), ("gin", 30)]


def test_sort_by_weight_empty():
    assert sort_by_weight([]) == []
