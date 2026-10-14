import ast
import inspect

import pytest

import mymodule
from mymodule import binary_search, count_checks, first_at_least, count_between

STARS = [2, 5, 8, 12, 16, 23, 38]
BIG = list(range(0, 3000, 3))   # 1000 sorted stars


def test_no_shortcuts():
    tree = ast.parse(inspect.getsource(mymodule))
    for node in ast.walk(tree):
        if isinstance(node, ast.Attribute) and node.attr == "index":
            pytest.fail(".index() isn't allowed: write the search yourself!")
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            names = [a.name for a in node.names] + [getattr(node, "module", None) or ""]
            if any("bisect" in n for n in names):
                pytest.fail("The bisect module isn't allowed: write the search yourself!")
        if isinstance(node, ast.Compare) and any(isinstance(op, (ast.In, ast.NotIn)) for op in node.ops):
            pytest.fail("Don't use `in` to search the list: that checks every star one by one.")


def test_binary_search_found():
    assert binary_search(STARS, 23) == 5
    assert binary_search(STARS, 2) == 0
    assert binary_search(STARS, 38) == 6


def test_binary_search_missing():
    assert binary_search(STARS, 7) == -1
    assert binary_search(STARS, 100) == -1
    assert binary_search([], 5) == -1


def test_binary_search_big():
    assert binary_search(BIG, 2997) == 999
    assert binary_search(BIG, 1500) == 500
    assert binary_search(BIG, 1501) == -1


def test_count_checks_first_middle():
    assert count_checks([1, 2, 3, 4, 5, 6, 7], 4) == 1


def test_count_checks_is_logarithmic():
    for target in [0, 1, 2997, 1500, 1501, 4000, -5]:
        checks = count_checks(BIG, target)
        assert 1 <= checks <= 10, "Searching 1000 stars took %d checks" % checks


def test_first_at_least():
    assert first_at_least([2, 5, 8, 12], 6) == 2
    assert first_at_least([2, 5, 8, 12], 5) == 1
    assert first_at_least([2, 5, 8, 12], 99) == 4
    assert first_at_least([2, 5, 8, 12], -1) == 0
    assert first_at_least([], 3) == 0


def test_first_at_least_duplicates():
    assert first_at_least([1, 3, 3, 3, 5], 3) == 1


def test_count_between():
    assert count_between([1, 3, 3, 5, 8, 9], 3, 8) == 4
    assert count_between([1, 3, 3, 5, 8, 9], 10, 20) == 0
    assert count_between(BIG, 0, 2997) == 1000


def test_count_checks_exact_on_seven():
    # With 7 stars, binary search needs 1 check for the middle, 2 for the
    # quarter points and 3 for the ends.
    stars = [1, 2, 3, 4, 5, 6, 7]
    assert [count_checks(stars, t) for t in stars] == [3, 2, 3, 1, 3, 2, 3]


def test_count_checks_missing_on_seven():
    assert count_checks([1, 2, 3, 4, 5, 6, 7], 0) == 3
    assert count_checks([1, 2, 3, 4, 5, 6, 7], 8) == 3
    assert count_checks([], 5) == 0
