import pytest

from mymodule import psi_to_bar, boiler_status


def test_psi_to_bar_examples():
    assert psi_to_bar(100) == pytest.approx(6.89)
    assert psi_to_bar(14.7) == pytest.approx(1.01)


def test_psi_to_bar_zero():
    assert psi_to_bar(0) == 0


def test_psi_to_bar_rounds():
    assert psi_to_bar(1) == pytest.approx(0.07)
    assert psi_to_bar(250) == pytest.approx(17.24)


def test_status_cold():
    assert boiler_status(0) == "cold"
    assert boiler_status(49.9) == "cold"


def test_status_steady():
    assert boiler_status(50) == "steady"
    assert boiler_status(100) == "steady"
    assert boiler_status(150) == "steady"


def test_status_hot():
    assert boiler_status(150.5) == "hot"
    assert boiler_status(199.5) == "hot"


def test_status_critical():
    assert boiler_status(200) == "critical"
    assert boiler_status(9000) == "critical"


def test_negative_pressure():
    with pytest.raises(ValueError):
        psi_to_bar(-1)
    with pytest.raises(ValueError):
        boiler_status(-0.5)
