from mymodule import fuel_by_ship, thirstiest, ships_below, refuel

RECORDS = [("Sparrow", 12), ("Behemoth", 40), ("Sparrow", 8), ("Kestrel", 5)]
LEDGER = {"Sparrow": 20, "Behemoth": 40, "Kestrel": 5}


def test_fuel_by_ship():
    assert fuel_by_ship(RECORDS) == LEDGER


def test_fuel_by_ship_empty():
    assert fuel_by_ship([]) == {}


def test_fuel_by_ship_one_ship_many_times():
    assert fuel_by_ship([("Zephyr", 1)] * 6) == {"Zephyr": 6}


def test_thirstiest():
    assert thirstiest(LEDGER) == "Behemoth"
    assert thirstiest({"Kestrel": 5}) == "Kestrel"


def test_thirstiest_empty():
    assert thirstiest({}) is None


def test_ships_below():
    assert ships_below(LEDGER, 25) == ["Kestrel", "Sparrow"]
    assert ships_below(LEDGER, 1) == []


def test_ships_below_sorted():
    ledger = {"Zephyr": 1, "Albatross": 2, "Moth": 3}
    assert ships_below(ledger, 10) == ["Albatross", "Moth", "Zephyr"]


def test_refuel_existing_and_new():
    ledger = {"Sparrow": 20}
    result = refuel(ledger, "Sparrow", 5)
    refuel(ledger, "Zephyr", 3)
    assert ledger == {"Sparrow": 25, "Zephyr": 3}
    assert result is None


def test_ships_below_exactly_at_threshold():
    assert ships_below({"Sparrow": 20, "Kestrel": 5}, 20) == ["Kestrel"]
