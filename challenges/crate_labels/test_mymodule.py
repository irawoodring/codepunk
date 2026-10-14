import pytest

from mymodule import label, money, manifest, progress_bar


def test_label():
    assert label("bearings", 12.5) == "BEARINGS....   12.50 kg"


def test_label_long_name_is_cut():
    assert label("brass fittings", 1200) == "BRASS FITTIN 1200.00 kg"


def test_label_width():
    assert len(label("x", 0)) == 23
    assert label("x", 0) == "X...........    0.00 kg"


def test_money():
    assert money(1234.5) == "$1,234.50"
    assert money(7) == "$7.00"
    assert money(1000000) == "$1,000,000.00"


def test_money_negative():
    assert money(-5) == "-$5.00"
    assert money(-1234.567) == "-$1,234.57"


def test_manifest():
    expected = ("TEA.........   30.00 kg\n"
                "COAL........  120.25 kg\n"
                "-----------------------\n"
                "TOTAL.......  150.25 kg")
    assert manifest([("tea", 30), ("coal", 120.25)]) == expected


def test_manifest_empty():
    assert manifest([]) == "-----------------------\nTOTAL.......    0.00 kg"


def test_progress_bar():
    assert progress_bar(5, 10) == "[#####-----] 50%"
    assert progress_bar(0, 10) == "[----------] 0%"
    assert progress_bar(10, 10) == "[##########] 100%"


def test_progress_bar_width():
    assert progress_bar(1, 3, 6) == "[##----] 33%"


def test_progress_bar_zero_total():
    with pytest.raises(ValueError):
        progress_bar(1, 0)


def test_money_zero_and_small():
    assert money(0) == "$0.00"
    assert money(0.5) == "$0.50"
    assert money(-0.5) == "-$0.50"
