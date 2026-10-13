from mymodule import reachable, shortest_route, isolated, pipes_needed

NETWORK = {
    "boiler": ["valves", "turbine"],
    "valves": ["boiler", "press"],
    "turbine": ["boiler", "press"],
    "press": ["valves", "turbine", "forge"],
    "forge": ["press"],
    "lantern": ["attic"],
    "attic": ["lantern"],
}

# A long loop with a shortcut: a-b-c-d-e-f-a, plus b-e.
RING = {
    "a": ["b", "f"],
    "b": ["a", "c", "e"],
    "c": ["b", "d"],
    "d": ["c", "e"],
    "e": ["d", "f", "b"],
    "f": ["e", "a"],
}


def is_valid_route(network, route):
    return all(route[i + 1] in network[route[i]] for i in range(len(route) - 1))


def test_reachable():
    assert reachable(NETWORK, "boiler") == {"boiler", "valves", "turbine", "press", "forge"}
    assert reachable(NETWORK, "attic") == {"attic", "lantern"}


def test_reachable_returns_set():
    assert type(reachable(NETWORK, "forge")) is set


def test_reachable_alone():
    assert reachable({"solo": []}, "solo") == {"solo"}


def test_shortest_route_length_and_validity():
    route = shortest_route(NETWORK, "boiler", "forge")
    assert route[0] == "boiler"
    assert route[-1] == "forge"
    assert len(route) == 4
    assert is_valid_route(NETWORK, route)


def test_shortest_route_uses_shortcut():
    route = shortest_route(RING, "c", "f")
    assert len(route) == 4
    assert is_valid_route(RING, route)
    assert shortest_route(RING, "b", "e") == ["b", "e"]


def test_shortest_route_same_place():
    assert shortest_route(NETWORK, "press", "press") == ["press"]


def test_shortest_route_none():
    assert shortest_route(NETWORK, "boiler", "attic") is None


def test_isolated():
    assert isolated(NETWORK, "boiler") == ["attic", "lantern"]
    assert isolated(RING, "c") == []


def test_pipes_needed():
    assert pipes_needed(NETWORK, "boiler", "forge") == 3
    assert pipes_needed(RING, "a", "e") == 2
    assert pipes_needed(NETWORK, "forge", "forge") == 0
    assert pipes_needed(NETWORK, "forge", "lantern") == -1
