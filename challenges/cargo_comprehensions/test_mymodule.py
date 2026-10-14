import pytest

from mymodule import heavy_names, in_tons, flatten, initials, cargo_grid

CRATES = {"tea": 30, "coal": 1200, "silk": 8, "iron": 950}


def test_heavy_names():
    assert heavy_names(CRATES, 100) == ["coal", "iron"]
    assert heavy_names(CRATES, 5000) == []
    assert heavy_names(CRATES, 0) == ["tea", "coal", "silk", "iron"]


def test_in_tons():
    assert in_tons(CRATES) == {"tea": 0.03, "coal": 1.2, "silk": 0.008, "iron": 0.95}


def test_in_tons_is_new_dict():
    crates = {"tea": 30}
    in_tons(crates)
    assert crates == {"tea": 30}


def test_flatten():
    assert flatten([["tea", "silk"], [], ["coal"]]) == ["tea", "silk", "coal"]
    assert flatten([]) == []


def test_initials():
    assert initials(["tea", "Tin", "coal", ""]) == {"T", "C"}
    assert initials([]) == set()


def test_cargo_grid():
    assert cargo_grid(2, 3) == [[".", ".", "."], [".", ".", "."]]
    assert cargo_grid(0, 5) == []


def test_cargo_grid_rows_are_separate():
    grid = cargo_grid(3, 2)
    grid[0][0] = "X"
    assert grid[1][0] == ".", "Changing row 0 also changed row 1: every row is the same list!"
    assert grid[2][0] == "."
