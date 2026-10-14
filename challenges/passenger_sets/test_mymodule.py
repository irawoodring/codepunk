from mymodule import unique_passengers, on_both, missing, only_one, has_duplicates


def test_unique_passengers():
    assert unique_passengers([["Ada", "Babbage"], ["Babbage", "Lovelace", "Ada"]]) == 3
    assert unique_passengers([["Ada", "Ada", "Ada"]]) == 1


def test_unique_passengers_empty():
    assert unique_passengers([]) == 0
    assert unique_passengers([[], []]) == 0


def test_on_both():
    assert on_both(["Ada", "Babbage", "Tesla"], ["Tesla", "Ada", "Curie"]) == ["Ada", "Tesla"]
    assert on_both(["Ada"], ["Curie"]) == []


def test_on_both_ignores_repeats():
    assert on_both(["Ada", "Ada"], ["Ada"]) == ["Ada"]


def test_missing():
    assert missing(["Ada", "Babbage", "Tesla"], ["Tesla"]) == ["Ada", "Babbage"]
    assert missing(["Ada"], ["Ada", "Curie"]) == []


def test_only_one():
    assert only_one(["Ada", "Babbage"], ["Babbage", "Curie"]) == ["Ada", "Curie"]
    assert only_one(["Ada"], ["Ada"]) == []


def test_has_duplicates():
    assert has_duplicates(["Ada", "Tesla", "Ada"]) is True
    assert has_duplicates(["Ada", "Tesla"]) is False
    assert has_duplicates([]) is False


def test_results_are_lists():
    assert type(on_both(["a"], ["a"])) is list
    assert type(missing(["a"], [])) is list
    assert type(only_one(["a"], [])) is list
