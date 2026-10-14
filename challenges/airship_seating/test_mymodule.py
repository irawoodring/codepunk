from mymodule import count_free, first_free, book, best_row, free_pairs


def chart():
    return [
        [".", "X", "."],
        ["X", "X", "X"],
        [".", ".", "X"],
    ]


def test_count_free():
    assert count_free(chart()) == 4
    assert count_free([["X", "X"]]) == 0
    assert count_free([]) == 0


def test_first_free():
    assert first_free(chart()) == (0, 0)
    assert first_free([["X", "X"], ["X", "."]]) == (1, 1)


def test_first_free_full():
    assert first_free([["X"], ["X"]]) is None


def test_book_free_seat():
    seats = chart()
    assert book(seats, 2, 1) is True
    assert seats[2][1] == "X"


def test_book_taken_seat():
    seats = chart()
    assert book(seats, 1, 1) is False
    assert seats == chart()


def test_book_off_the_chart():
    seats = chart()
    assert book(seats, 9, 0) is False
    assert book(seats, 0, 9) is False
    assert book(seats, -1, 0) is False
    assert seats == chart()


def test_best_row():
    assert best_row(chart()) == 0
    assert best_row([["X", "."], [".", "."], [".", "."]]) == 1
    assert best_row([]) is None


def test_free_pairs():
    assert free_pairs([[".", ".", "."], [".", "X", "."]]) == 2
    assert free_pairs(chart()) == 1
    assert free_pairs([["."]]) == 0


def test_book_corner_seats():
    seats = [[".", "."], [".", "."]]
    assert book(seats, 0, 0) is True
    assert book(seats, 1, 1) is True
    assert seats == [["X", "."], [".", "X"]]


def test_book_just_off_the_edge():
    seats = chart()
    assert book(seats, 3, 0) is False
    assert book(seats, 0, 3) is False
    assert seats == chart()


def test_book_negative_column():
    # In Python, seats[0][-1] is the LAST seat, so check for negatives yourself!
    seats = chart()
    assert book(seats, 0, -1) is False
    assert seats == chart()


def test_best_row_single_row():
    assert best_row([["X", "."]]) == 0
