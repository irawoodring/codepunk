import pytest

from mymodule import is_sealed, first_leak, max_depth


def test_sealed_examples():
    assert is_sealed("(--[==]--{<>})") is True
    assert is_sealed("pipe") is True
    assert is_sealed("") is True


def test_not_sealed_examples():
    assert is_sealed("(--[==)--]") is False
    assert is_sealed("((") is False
    assert is_sealed("))") is False


def test_order_matters():
    assert is_sealed("([)]") is False
    assert is_sealed("([])") is True


def test_first_leak_wrong_closer():
    assert first_leak("(--[==)--]") == 6


def test_first_leak_closer_with_no_opener():
    assert first_leak("]") == 0
    assert first_leak("()>") == 2


def test_first_leak_unclosed_opener():
    assert first_leak("a(b[c]d") == 1
    assert first_leak("<>{(") == 2


def test_first_leak_sealed():
    assert first_leak("{<>}") == -1
    assert first_leak("") == -1


def test_max_depth():
    assert max_depth("(--[==]--{<>})") == 3
    assert max_depth("--") == 0
    assert max_depth("()()()") == 1


def test_max_depth_not_sealed():
    with pytest.raises(ValueError):
        max_depth("(()")
