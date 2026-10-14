import pytest

from mymodule import parse_weight, total_weight, lookup_berth, split_load


def test_parse_weight_formats():
    assert parse_weight("12.5kg") == pytest.approx(12.5)
    assert parse_weight(" 40 kg ") == pytest.approx(40.0)
    assert parse_weight("7") == pytest.approx(7.0)


def test_parse_weight_returns_float():
    assert type(parse_weight("7kg")) is float


def test_parse_weight_bad_text():
    with pytest.raises(ValueError):
        parse_weight("heavy")
    with pytest.raises(ValueError):
        parse_weight("")
    with pytest.raises(ValueError):
        parse_weight("kg")


def test_parse_weight_negative():
    with pytest.raises(ValueError):
        parse_weight("-3kg")


def test_total_weight():
    assert total_weight(["10kg", "oops", "2.5 kg", "", "-1"]) == (pytest.approx(12.5), 3)


def test_total_weight_all_good_or_empty():
    assert total_weight(["1kg", "2kg"]) == (pytest.approx(3.0), 0)
    assert total_weight([]) == (0, 0)


def test_total_weight_rounds():
    assert total_weight(["0.1", "0.2"]) == (pytest.approx(0.3), 0)


def test_lookup_berth():
    berths = {"Sparrow": 4, "Behemoth": 1}
    assert lookup_berth(berths, "Sparrow") == 4
    assert lookup_berth(berths, "Kestrel") == "UNASSIGNED"
    assert lookup_berth({}, "Anyone") == "UNASSIGNED"


def test_split_load():
    assert split_load(100, 3) == pytest.approx(33.33)
    assert split_load(90, 2) == pytest.approx(45.0)


def test_split_load_zero_holds():
    assert split_load(100, 0) is None


def test_parse_weight_zero_is_fine():
    assert parse_weight("0kg") == 0


def test_total_weight_rounds_to_two_places():
    assert total_weight(["1.111", "2.222"]) == (pytest.approx(3.33), 0)


def test_lookup_berth_zero():
    assert lookup_berth({"Moth": 0}, "Moth") == 0
