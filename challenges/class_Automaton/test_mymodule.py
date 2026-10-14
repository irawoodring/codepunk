import pytest

from mymodule import Automaton, WelderBot, CourierBot, total_steam


def test_automaton_basics():
    a = Automaton("Tock")
    assert a.name == "Tock"
    assert a.steam == 100
    assert Automaton("Tick", 30).steam == 30


def test_automaton_work():
    a = Automaton("Tock")
    a.work(6)
    assert a.steam == 40


def test_work_without_enough_steam():
    a = Automaton("Tock", 25)
    with pytest.raises(RuntimeError):
        a.work(3)
    assert a.steam == 25


def test_refuel_caps_at_100():
    a = Automaton("Tock", 10)
    a.refuel(20)
    assert a.steam == 30
    a.refuel(500)
    assert a.steam == 100


def test_describe():
    a = Automaton("Tock")
    a.work(6)
    assert a.describe() == "Tock the Automaton (40 steam)"


def test_subclasses_are_automatons():
    assert isinstance(WelderBot("Sparky"), Automaton)
    assert isinstance(CourierBot("Dash"), Automaton)


def test_welder_burns_faster():
    w = WelderBot("Sparky")
    w.work(2)
    assert w.steam == 70


def test_welder_weld():
    w = WelderBot("Sparky", 12)
    assert w.welds == 0
    w.weld()
    w.weld()
    assert w.welds == 2
    assert w.steam == 2
    with pytest.raises(RuntimeError):
        w.weld()
    assert w.welds == 2


def test_courier():
    c = CourierBot("Dash")
    c.work(4)
    assert c.steam == 80
    c.deliver("letter")
    c.deliver("tea")
    assert c.parcels == ["letter", "tea"]
    assert c.steam == 76


def test_couriers_have_separate_parcels():
    a, b = CourierBot("A"), CourierBot("B")
    a.deliver("x")
    assert b.parcels == []


def test_courier_out_of_steam():
    c = CourierBot("Dash", 1)
    with pytest.raises(RuntimeError):
        c.deliver("letter")
    assert c.parcels == []


def test_describe_uses_subclass_name():
    assert WelderBot("Sparky").describe() == "Sparky the WelderBot (100 steam)"
    assert CourierBot("Dash", 50).describe() == "Dash the CourierBot (50 steam)"


def test_total_steam():
    bots = [Automaton("A", 10), WelderBot("B", 20), CourierBot("C", 30)]
    assert total_steam(bots) == 60
    assert total_steam([]) == 0


def test_work_can_use_every_last_drop():
    a = Automaton("Tock", 30)
    a.work(3)
    assert a.steam == 0


def test_weld_with_exactly_enough_steam():
    w = WelderBot("Sparky", 5)
    w.weld()
    assert w.steam == 0
    assert w.welds == 1
