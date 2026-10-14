from mymodule import orbit_paths, fewest_lenses, longest_shared_signal


def test_orbit_paths_small():
    assert orbit_paths(0) == 1
    assert orbit_paths(1) == 1
    assert orbit_paths(2) == 2
    assert orbit_paths(3) == 3
    assert orbit_paths(10) == 89


def test_orbit_paths_big_and_fast():
    assert orbit_paths(80) == 37889062373143906


def test_fewest_lenses():
    assert fewest_lenses(11, [1, 2, 5]) == 3
    assert fewest_lenses(0, [1, 2]) == 0


def test_fewest_lenses_greedy_trap():
    assert fewest_lenses(63, [1, 5, 10, 21, 25]) == 3


def test_fewest_lenses_impossible():
    assert fewest_lenses(3, [2]) == -1
    assert fewest_lenses(1001, [6, 10]) == -1


def test_fewest_lenses_big():
    assert fewest_lenses(999, [7, 13, 29]) == 35
    assert fewest_lenses(1000, [6, 10]) == 100


def test_longest_shared_signal():
    assert longest_shared_signal("ABCBDAB", "BDCABA") == 4
    assert longest_shared_signal("STEAMPUNK", "SPANNER") == 3
    assert longest_shared_signal("", "ABC") == 0
    assert longest_shared_signal("SAME", "SAME") == 4


def test_longest_shared_signal_big():
    assert longest_shared_signal("AB" * 150, "BA" * 150) == 299


def test_fewest_lenses_single_lens():
    assert fewest_lenses(1, [1]) == 1
    assert fewest_lenses(7, [7]) == 1
    assert fewest_lenses(10, [5, 1]) == 2


def test_fewest_lenses_more_greedy_traps():
    assert fewest_lenses(12, [1, 6, 10]) == 2
    assert fewest_lenses(6, [4, 3, 1]) == 2


def test_fewest_lenses_prefers_the_better_lens():
    assert fewest_lenses(2, [1, 2]) == 1
    assert fewest_lenses(4, [1, 2]) == 2
