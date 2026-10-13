import ast
import inspect
import textwrap

import pytest

import mymodule
from mymodule import spin, train_ratio, count_cogs, blueprint_depth


def calls_itself(fn):
    tree = ast.parse(textwrap.dedent(inspect.getsource(fn)))
    return any(
        isinstance(node, ast.Call)
        and isinstance(node.func, ast.Name)
        and node.func.id == fn.__name__
        for node in ast.walk(tree)
    )


@pytest.mark.parametrize("fn", [spin, train_ratio, count_cogs, blueprint_depth])
def test_is_recursive(fn):
    if not calls_itself(fn):
        pytest.fail(fn.__name__ + " must call itself (use recursion, not a loop).")


def test_spin():
    assert spin(1) == "clockwise"
    assert spin(2) == "counterclockwise"
    assert spin(4) == "counterclockwise"
    assert spin(7) == "clockwise"


def test_train_ratio():
    assert train_ratio([10, 20, 40]) == pytest.approx(4.0)
    assert train_ratio([40, 20, 10]) == pytest.approx(0.25)


def test_train_ratio_single():
    assert train_ratio([12]) == pytest.approx(1.0)


def test_count_cogs():
    assert count_cogs([1, 2, [3, 4, [5]], 6]) == 6
    assert count_cogs([7, 7, 7]) == 3


def test_count_cogs_empty():
    assert count_cogs([]) == 0
    assert count_cogs([[], [[]]]) == 0


def test_blueprint_depth():
    assert blueprint_depth([1, 2, 3]) == 1
    assert blueprint_depth([]) == 1
    assert blueprint_depth([1, [2, [3]], [4]]) == 3


def test_blueprint_depth_deep():
    assert blueprint_depth([[[[[]]]]]) == 5
