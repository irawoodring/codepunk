import pytest

from mymodule import ratio, output_rpm, full_turns


def test_ratio_examples():
    assert ratio(10, 30) == pytest.approx(3.0)
    assert ratio(12, 8) == pytest.approx(0.67)


def test_ratio_equal_gears():
    assert ratio(20, 20) == pytest.approx(1.0)


def test_output_rpm_examples():
    assert output_rpm(300, 10, 30) == pytest.approx(100.0)
    assert output_rpm(90, 12, 8) == pytest.approx(135.0)


def test_output_rpm_rounds():
    assert output_rpm(100, 7, 3) == pytest.approx(233.3)


def test_full_turns_examples():
    assert full_turns(800) == (2, 80)
    assert full_turns(360) == (1, 0)
    assert full_turns(45) == (0, 45)


def test_full_turns_zero_and_big():
    assert full_turns(0) == (0, 0)
    assert full_turns(3601) == (10, 1)


def test_full_turns_returns_tuple():
    assert type(full_turns(500)) is tuple


def test_bad_teeth():
    with pytest.raises(ValueError):
        ratio(0, 10)
    with pytest.raises(ValueError):
        ratio(10, -2)
    with pytest.raises(ValueError):
        output_rpm(100, 10, 0)
