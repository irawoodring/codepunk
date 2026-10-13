from mymodule import count_open, longest_closed_run, toggle, first_closed


def test_count_open():
    assert count_open("OOXOXXXO") == 4
    assert count_open("XXX") == 0
    assert count_open("") == 0


def test_longest_closed_run():
    assert longest_closed_run("OOXOXXXO") == 3
    assert longest_closed_run("XXOXXXXX") == 5


def test_longest_closed_run_none_closed():
    assert longest_closed_run("OOO") == 0
    assert longest_closed_run("") == 0


def test_longest_closed_run_ends_closed():
    assert longest_closed_run("OXXXX") == 4


def test_toggle():
    assert toggle("OOXOX") == "XXOXO"
    assert toggle("") == ""


def test_toggle_twice_is_original():
    assert toggle(toggle("OXXOOXO")) == "OXXOOXO"


def test_first_closed():
    assert first_closed("OOXOX") == 2
    assert first_closed("XOO") == 0


def test_first_closed_none():
    assert first_closed("OO") == -1
    assert first_closed("") == -1
