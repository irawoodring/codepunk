import random

from mymodule import StarNode, ConstellationTree

STARS = ["Polaris", "Altair", "Vega", "Betelgeuse"]


def build(names=STARS):
    t = ConstellationTree()
    for n in names:
        t.insert(n)
    return t


def test_empty_tree():
    t = ConstellationTree()
    assert t.root is None
    assert len(t) == 0
    assert t.in_order() == []
    assert t.height() == 0
    assert t.first() is None and t.last() is None
    assert ("Vega" in t) is False


def test_insert_shape():
    t = build()
    assert isinstance(t.root, StarNode)
    assert t.root.name == "Polaris"
    assert t.root.left.name == "Altair"
    assert t.root.right.name == "Vega"
    assert t.root.left.right.name == "Betelgeuse"


def test_insert_returns():
    t = ConstellationTree()
    assert t.insert("Vega") is True
    assert t.insert("Vega") is False
    assert len(t) == 1


def test_contains():
    t = build()
    assert "Altair" in t
    assert "Betelgeuse" in t
    assert "Sirius" not in t


def test_len():
    assert len(build()) == 4


def test_in_order():
    assert build().in_order() == ["Altair", "Betelgeuse", "Polaris", "Vega"]


def test_height():
    assert build().height() == 3
    assert build(["M"]).height() == 1
    assert build(["A", "B", "C", "D"]).height() == 4


def test_first_and_last():
    t = build()
    assert t.first() == "Altair"
    assert t.last() == "Vega"


def test_many_random_stars():
    rng = random.Random(7)
    names = ["Star%03d" % i for i in range(200)]
    rng.shuffle(names)
    t = build(names)
    assert len(t) == 200
    assert t.in_order() == sorted(names)
    assert all(n in t for n in names[:20])
    assert "Star999" not in t
