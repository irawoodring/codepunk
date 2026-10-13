import pytest

from mymodule import chimes, chime_pattern, total_chimes, quiet_hours


def test_chimes_morning():
    assert chimes(1) == 1
    assert chimes(3) == 3
    assert chimes(12) == 12


def test_chimes_afternoon():
    assert chimes(13) == 1
    assert chimes(15) == 3
    assert chimes(23) == 11


def test_chimes_midnight():
    assert chimes(0) == 12


def test_chimes_bad_hour():
    with pytest.raises(ValueError):
        chimes(24)
    with pytest.raises(ValueError):
        chimes(-1)


def test_chime_pattern():
    assert chime_pattern(3) == "BONG BONG BONG"
    assert chime_pattern(13) == "BONG"


def test_chime_pattern_no_extra_spaces():
    assert chime_pattern(0) == " ".join(["BONG"] * 12)


def test_total_chimes():
    assert total_chimes(1, 3) == 6
    assert total_chimes(5, 5) == 5


def test_total_chimes_whole_day():
    assert total_chimes(0, 23) == 156


def test_quiet_hours():
    assert quiet_hours(3) == [1, 2, 13, 14]
    assert quiet_hours(1) == []
