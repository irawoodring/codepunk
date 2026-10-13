from mymodule import total_weight, heaviest, overweight, load_airship

CRATES = [120, 45, 300, 80, 210]


def test_total_weight():
    assert total_weight(CRATES) == 755
    assert total_weight([7]) == 7


def test_total_weight_empty():
    assert total_weight([]) == 0


def test_heaviest():
    assert heaviest(CRATES) == 300
    assert heaviest([5, 9, 9, 1]) == 9


def test_heaviest_empty():
    assert heaviest([]) is None


def test_overweight():
    assert overweight(CRATES, 100) == [120, 300, 210]
    assert overweight(CRATES, 1000) == []


def test_overweight_does_not_change_original():
    crates = [10, 200, 30]
    overweight(crates, 50)
    assert crates == [10, 200, 30]


def test_load_airship():
    assert load_airship(CRATES, 500) == 3
    assert load_airship(CRATES, 755) == 5


def test_load_airship_exact_fit():
    assert load_airship([100, 100, 100], 200) == 2


def test_load_airship_nothing_fits():
    assert load_airship([600, 10], 500) == 0
    assert load_airship([], 500) == 0
