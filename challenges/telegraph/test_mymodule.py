from mymodule import encode, decode, longest_word


def test_encode_one_word():
    assert encode("SOS") == "... --- ..."


def test_encode_lowercase():
    assert encode("sos") == "... --- ..."


def test_encode_two_words():
    assert encode("hi there") == ".... .. / - .... . .-. ."


def test_encode_single_letter():
    assert encode("E") == "."


def test_decode_one_word():
    assert decode("... --- ...") == "SOS"


def test_decode_two_words():
    assert decode(".... .. / - .... . .-. .") == "HI THERE"


def test_round_trip():
    message = "STEAM IS RISING"
    assert decode(encode(message)) == message


def test_longest_word():
    assert longest_word("--. --- / . .- ... -") == "EAST"


def test_longest_word_tie_returns_first():
    assert longest_word(encode("cog gear nut bolt")) == "GEAR"


def test_every_letter():
    # The official Cogsworth table. (Don't change MORSE in your code!)
    official = {
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.",
        "G": "--.", "H": "....", "I": "..", "J": ".---", "K": "-.-", "L": ".-..",
        "M": "--", "N": "-.", "O": "---", "P": ".--.", "Q": "--.-", "R": ".-.",
        "S": "...", "T": "-", "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
        "Y": "-.--", "Z": "--..",
    }
    pangram = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"
    expected = " / ".join(" ".join(official[c] for c in word) for word in pangram.split())
    assert encode(pangram) == expected
    assert decode(expected) == pangram
