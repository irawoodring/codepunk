import pytest

from mymodule import Gear


def test_attributes():
    g = Gear(12)
    assert g.teeth == 12
    assert g.material == "brass"


def test_custom_material():
    assert Gear(30, "steel").material == "steel"


def test_too_few_teeth():
    with pytest.raises(ValueError):
        Gear(5)
    Gear(6)  # exactly six is fine


def test_repr():
    assert repr(Gear(12)) == "Gear(12, 'brass')"
    assert repr(Gear(40, "steel")) == "Gear(40, 'steel')"


def test_equality():
    assert Gear(12) == Gear(12)
    assert not (Gear(12) == Gear(12, "steel"))
    assert not (Gear(12) == Gear(13))


def test_less_than():
    assert Gear(10) < Gear(20)
    assert not (Gear(20) < Gear(10))


def test_sorting_uses_less_than():
    gears = [Gear(30), Gear(8), Gear(16)]
    assert [g.teeth for g in sorted(gears)] == [8, 16, 30]


def test_mesh_ratio():
    assert Gear(10).mesh_ratio(Gear(30)) == pytest.approx(3.0)
    assert Gear(30).mesh_ratio(Gear(10)) == pytest.approx(0.33)


def test_is_compatible():
    assert Gear(10).is_compatible(Gear(50)) is True
    assert Gear(10).is_compatible(Gear(10, "steel")) is False
