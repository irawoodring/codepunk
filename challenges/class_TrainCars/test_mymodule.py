from mymodule import Car, Train


def build(*cargo):
    t = Train()
    for c in cargo:
        t.attach(c)
    return t


def test_new_train_is_empty():
    t = Train()
    assert t.head is None
    assert len(t) == 0
    assert t.to_list() == []


def test_attach():
    t = build("coal", "tea")
    assert t.to_list() == ["coal", "tea"]
    assert len(t) == 2


def test_uses_linked_cars():
    t = build("coal", "tea")
    assert isinstance(t.head, Car)
    assert t.head.cargo == "coal"
    assert t.head.next.cargo == "tea"
    assert t.head.next.next is None


def test_couple_front():
    t = build("coal", "tea")
    t.couple_front("engine")
    assert t.to_list() == ["engine", "coal", "tea"]
    assert t.head.cargo == "engine"


def test_couple_front_on_empty_train():
    t = Train()
    t.couple_front("engine")
    t.attach("caboose")
    assert t.to_list() == ["engine", "caboose"]


def test_detach_middle():
    t = build("engine", "coal", "tea")
    assert t.detach("coal") is True
    assert t.to_list() == ["engine", "tea"]


def test_detach_head_and_tail():
    t = build("engine", "coal", "tea")
    assert t.detach("engine") is True
    assert t.detach("tea") is True
    assert t.to_list() == ["coal"]


def test_detach_first_match_only():
    t = build("coal", "tea", "coal")
    t.detach("coal")
    assert t.to_list() == ["tea", "coal"]


def test_detach_missing():
    t = build("coal")
    assert t.detach("gold") is False
    assert Train().detach("gold") is False
    assert t.to_list() == ["coal"]


def test_reverse():
    t = build("engine", "coal", "tea", "caboose")
    t.reverse()
    assert t.to_list() == ["caboose", "tea", "coal", "engine"]


def test_reverse_keeps_same_cars():
    t = build("a", "b")
    first = t.head
    t.reverse()
    assert t.head.next is first
    assert first.next is None


def test_reverse_empty_and_single():
    t = Train()
    t.reverse()
    assert t.to_list() == []
    t.attach("solo")
    t.reverse()
    assert t.to_list() == ["solo"]
