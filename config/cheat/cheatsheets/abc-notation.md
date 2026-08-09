# ABC Music Notation Cheat Sheet

ABC notation is a plain-text way to write music. You type letters for notes,
numbers for how long they last, and a tiny header that says what key/time
signature you're in. Any text editor works; the file is usually saved as
`tune.abc`.

---

# The 10-second version

```text
C D E F G A B c      notes (lowercase = one octave higher)
C, C,, C,,,          commas lower the octave
c' c'' c'''          apostrophes raise the octave
C2 C1/2 C4           number after the note = how many beats it lasts
z z2                 z = rest
^F _B =C             sharp, flat, natural (standard ABC spelling)
| || |: :| [1 [2     barlines, repeats, alternate endings
- ( ) [CEG] "C"      tie, slur, chord, chord symbol
```

A complete tune:

```text
X:1
T:Twinkle, Twinkle, Little Star
M:4/4
L:1/4
K:C
C C G G | A A G2 | F F E E | D D C2 |
```

Every tune needs at least `X:`, `T:`, and `K:`. The key `K:` is the only one
that is strictly required; you almost always want `M:` (time signature) and
`L:` (default note length) too.

---

# Notes and octaves

## Note names

Notes are the letters A through G. There is no H. **Capitalization matters** —
it changes the octave.

## The one octave rule to memorize

```text
c d e f g a b      lowercase  = the octave with middle C (c = middle C)
C D E F G A B      UPPERCASE  = one octave below middle C
C,  C,,  C,,,      commas     = each comma drops it one more octave
c'  c''  c'''      apostrophes = each apostrophe raises it one octave
```

So `c` is middle C, `C` is the C below it, and `c'` is the C above it. Add
more commas or apostrophes to climb or dive further.

| Piano note | ABC |
|------------|-----|
| middle C (C4) | `c` |
| C an octave below middle C (C3) | `C` |
| C two octaves down (C2) | `C,` |
| C three octaves down (C1) | `C,,` |
| one octave above middle C (C5) | `c'` |
| two octaves up (C6) | `c''` |

## Lowest and highest note on a piano

A standard 88-key piano spans A0 (the lowest key) to C8 (the highest key).
In ABC:

```text
Lowest note on the piano:    A,,,
Highest note on the piano:   c''''
```

You can keep going beyond either end (`A,,,,`, `c'''''`, ...), but on the
piano those keys simply don't exist.

---

# Note lengths (beats)

The number written right after a note multiplies the default note length.
Here's the trick that makes it feel like "number = beats":

Set `L:1/4` in the header. Then the default note (just a bare letter) is a
quarter note = 1 beat, and the number after a note literally means beats.

With `L:1/4`:

| ABC | Name | Lasts |
|-----|------|-------|
| `C` | quarter note | 1 beat |
| `C1` | quarter note | 1 beat (same as bare `C`) |
| `C2` | half note | 2 beats |
| `C3` | dotted half | 3 beats |
| `C4` | whole note | 4 beats |
| `C1/2` | eighth note | 1/2 beat |
| `C3/2` | dotted quarter | 1 1/2 beats |
| `C/` | eighth note | 1/2 beat (shorthand for `C1/2`) |
| `C1/4` | sixteenth note | 1/4 beat |

If you change `L:`, the numbers scale accordingly (with `L:1/8`, bare `C` is
an eighth note and `C2` is a quarter). If you leave `L:` out entirely, the ABC
standard assumes 1/8 — which is why people get surprised that their "1 beat"
notes turn out too short. Just set `L:1/4`.

## Rests

Rests are written with `z` (some tools also accept `r`):

```text
z      1-beat rest
z2     2-beat rest
z1/2   half-beat rest
z/     half-beat rest (shorthand)
z4     whole-bar rest
```

## Accidentals

In standard ABC, accidentals go **before** the note:

```text
^F     F sharp
_B     B flat
=C     C natural
^^C    double sharp
__B    double flat
```

Your reference text writes them as `F#` and `Bb` — that's the friendly
spelling. It works in some beginner tools, but almost every real ABC file and
player uses `^` and `_`, so learn those.

Note: the key signature does the usual work for you. With `K:G`, every F is
automatically F sharp, so you only write `^`/`_` for notes *outside* the key.

---

# Bars, repeats, endings

| Symbol | Meaning |
|--------|---------|
| `\|` | barline (one measure) |
| `\|\|` | double barline (end of a section) |
| `\|]` | end of the tune |
| `\|:` | start of a repeat |
| `:\|` | end of a repeat |
| `[1` / `[2` | first / second ending |
| `[I:` / `I:` | instruction lines (rarely needed) |

Repeat with alternate endings:

```text
|: C D | E F | [1 G A :| [2 C C |]
```

Play bars 1–2, then the first ending (G A); repeat from the `|:`, play bars
1–2 again, then skip the first ending and play the second ending (C C) to
finish.

---

# Ties, slurs, chords

```text
C2-C2      tie        hold the C across the barline (same pitch; don't re-play it)
(C D E)    slur       play the notes in one smooth phrase
[CEG]      chord      play all three notes at once
"C7"       chord symbol  text shown above the staff (for the guitarist)
```

---

# Key, time, tempo

```text
K:C     C major          K:Cm    C minor
K:G     G major          K:Am    A minor
K:D     D major          K:Dm    D minor
K:F     F major          K:Em    E minor

M:4/4   4/4 time         M:3/4   waltz time
M:6/8   6/8 time         M:C     4/4   (C = common time)
M:C|    cut time

Q:1/4=120   play at 120 quarter notes per minute
```

---

# Decoding your help snippet

Your reference line `C1 . F#1 D1/2 E2 . C' C, C,2 . C2 z1 E1` translates to
standard ABC as:

```text
C ^F D/2 E2 | c' C, C,2 | C2 z E |
```

Breaking it down (with `L:1/4`, so number = beats):

```text
C      C, played for 1 beat
^F     F sharp (your F#), 1 beat
D/2    D for half a beat
E2     E for 2 beats
c'     C one octave up, 1 beat
C,     C one octave down, 1 beat
C,2    C one octave down, 2 beats
C2     C for 2 beats
z      rest for 1 beat
E      E for 1 beat
```

The `.` in your snippet is just a visual phrase separator — in ABC, spaces
between notes serve that role, and `|` marks real bar lines.

---

# Complete example tunes

Each of these is a full, copy-paste-able ABC file.

## Twinkle, Twinkle, Little Star

```text
X:1
T:Twinkle, Twinkle, Little Star
M:4/4
L:1/4
K:C
C C G G | A A G2 | F F E E | D D C2 |
G G F F | E E D2 | G G F F | E E D2 |
C C G G | A A G2 | F F E E | D D C2 |
```

## Mary Had a Little Lamb

```text
X:1
T:Mary Had a Little Lamb
M:4/4
L:1/4
K:C
E D C D | E E E2 | D D D2 | E G G2 |
E D C D | E E E E | D D E D | C4 |
```

## Ode to Joy

```text
X:1
T:Ode to Joy
M:4/4
L:1/4
K:C
E E F G | G F E D | C C D E | E D D2 |
E E F G | G F E D | C C D E | D C C2 |
```

## Happy Birthday

```text
X:1
T:Happy Birthday
M:3/4
L:1/4
K:C
G/G/ A G | c B2 | G/G/ A G | d c2 |
G/G/ g e | c B A | f/f/ e c | d c2 |
```

Notes on this one: `G/G/` is two quick eighth notes ("Hap-py"), which is the
pickup before the downbeat. Want it in a brighter register? Add apostrophes to
lift the whole tune one octave: `g/g/ a g | c' b2 | ...`.

---

# Gotchas

- No H, no sharp-symbol note names — only the letters A through G.
- Bare notes default to 1/8 length unless you set `L:1/4`. The "number =
  beats" rule only holds because of that `L:1/4`.
- `C1` and `C` are the same thing; the `1` is redundant but harmless.
- Accidentals attach to the next note and are spelled `^`/`_`, not `#`/`b`.
- Spaces between notes are optional (`CDEF` is fine) but make music far more
  readable.
- Every tune needs a `K:` line or most players will refuse to open it.

---

# Tools to try

- **In the browser (instant):** https://abcnotation.com/abcjs — paste ABC and
  it renders sheet music and plays it.
- **Command line:** `abcm2ps` (typeset to PDF/PS) and `abc2midi` (make a
  playable MIDI). On Arch: `sudo pacman -S abcm2ps abcMIDI`.
- **abcjs API:** embed rendering/playback into your own web pages.

---

# Related

- `cheat music-chords` — chord spellings if you want to add guitar chords
  above your ABC melody (`"C" "F" "G7"` etc.).
- If you're converting a LilyPond file to ABC (or vice versa), check
  `cheat lilypond-notation`.
