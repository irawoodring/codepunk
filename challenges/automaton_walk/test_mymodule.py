from mymodule import final_position, steps_until_home, walk_grid

GRID = [
    "....",
    ".#..",
    "A...",
]


def test_final_position_examples():
    assert final_position("NNE") == (1, 2)
    assert final_position("NESW") == (0, 0)


def test_final_position_empty():
    assert final_position("") == (0, 0)


def test_final_position_ignores_junk():
    assert final_position("N?N") == (0, 2)
    assert final_position("WWS x") == (-2, -1)


def test_steps_until_home():
    assert steps_until_home("NESW") == 4
    assert steps_until_home("NSNS") == 2


def test_steps_until_home_never():
    assert steps_until_home("NNN") == -1
    assert steps_until_home("") == -1


def test_walk_grid_open_path():
    assert walk_grid(GRID, "NNE") == (0, 1)
    assert walk_grid(GRID, "EEE") == (2, 3)


def test_walk_grid_blocked_by_wall():
    assert walk_grid(GRID, "ENN") == (2, 1)


def test_walk_grid_edges():
    assert walk_grid(GRID, "WWSS") == (2, 0)
    assert walk_grid(GRID, "NNNNEEEEEE") == (0, 3)


def test_walk_grid_start_elsewhere():
    grid = ["#.#", ".A.", "#.#"]
    assert walk_grid(grid, "N") == (0, 1)
    assert walk_grid(grid, "NE") == (0, 1)
