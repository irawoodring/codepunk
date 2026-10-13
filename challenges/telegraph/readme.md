# Telegraph Office

The old telegraph office is locked tight. A message is still sitting on the wire, and the chest inside only opens for someone who can **send and receive Morse code**.

The `MORSE` dictionary at the top of your code maps each letter to its code. **Don't change it.**

## The Format

* Letters in a word are separated by **one space**.
* Words are separated by **` / `** (space, slash, space).

So `"SOS HELP"` is sent as:

```
... --- ... / .... . .-.. .--.
```

## Your Mission

### 1. `encode(text)`

Turn `text` into Morse code. Treat lowercase letters like uppercase (`"sos"` is the same as `"SOS"`). You can assume the text only has letters and single spaces.

```python
encode("SOS")       # "... --- ..."
encode("hi there")  # ".... .. / - .... . .-. ."
```

### 2. `decode(signal)`

Turn a Morse `signal` back into **uppercase** text, with single spaces between words.

```python
decode("... --- ...")                # "SOS"
decode(".... .. / - .... . .-. .")   # "HI THERE"
```

### 3. `longest_word(signal)`

Decode the signal and return the longest word. If two words tie, return the one that comes first.

```python
longest_word("--. --- / . .- ... -")  # "EAST"
```

**Hint:** `" ".join(["A", "B"])` gives `"A B"`.
