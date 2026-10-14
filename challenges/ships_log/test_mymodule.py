import os
import tempfile

from mymodule import write_log, read_log, append_entry, count_events

ENTRIES = ["DEPART Sparrow 09:00", "ARRIVE Behemoth 09:45", "DEPART Kestrel 10:15"]


def make_path(name="log.txt"):
    folder = tempfile.mkdtemp()
    return os.path.join(folder, name)


def test_write_then_read():
    path = make_path()
    write_log(path, ENTRIES)
    assert read_log(path) == ENTRIES


def test_write_one_entry_per_line():
    path = make_path()
    write_log(path, ENTRIES)
    with open(path) as f:
        assert f.read().splitlines() == ENTRIES


def test_write_replaces_old_log():
    path = make_path()
    write_log(path, ENTRIES)
    write_log(path, ["ARRIVE Zephyr 12:00"])
    assert read_log(path) == ["ARRIVE Zephyr 12:00"]


def test_read_missing_file():
    assert read_log(make_path("nothing_here.txt")) == []


def test_read_file_written_elsewhere():
    path = make_path()
    with open(path, "w") as f:
        f.write("ARRIVE Moth 08:00\nDEPART Moth 08:30\n")
    assert read_log(path) == ["ARRIVE Moth 08:00", "DEPART Moth 08:30"]


def test_append_entry():
    path = make_path()
    write_log(path, ENTRIES)
    append_entry(path, "ARRIVE Zephyr 12:00")
    assert read_log(path) == ENTRIES + ["ARRIVE Zephyr 12:00"]


def test_append_to_new_file():
    path = make_path()
    append_entry(path, "ARRIVE Zephyr 12:00")
    append_entry(path, "DEPART Zephyr 13:00")
    assert read_log(path) == ["ARRIVE Zephyr 12:00", "DEPART Zephyr 13:00"]


def test_count_events():
    path = make_path()
    write_log(path, ENTRIES)
    assert count_events(path, "DEPART") == 2
    assert count_events(path, "ARRIVE") == 1
    assert count_events(path, "REFUEL") == 0


def test_count_events_start_of_line_only():
    path = make_path()
    write_log(path, ["ARRIVE DEPART-Express 07:00"])
    assert count_events(path, "DEPART") == 0
