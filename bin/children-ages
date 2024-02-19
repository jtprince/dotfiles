#!/usr/bin/env python

from dataclasses import dataclass
from datetime import date, datetime
from itertools import groupby
from pathlib import Path
from typing import Optional


@dataclass(frozen=True)
class Person:
    name: str
    birthday: date
    social_security: Optional[str] = None

    def age(self):
        today = date.today()
        return (
            today.year
            - self.birthday.year
            - ((today.month, today.day) < (self.birthday.month, self.birthday.day))
        )


def cast_block(block):
    """Takes a list of 3 elements and turns it into a Person."""
    birthday = datetime.strptime(block[-1], "%m/%d/%Y").date()
    return Person(name=block[0], social_security=block[1], birthday=birthday)


_FILE_PATH = "Dropbox/family/BDAYS_AND_SS_NUMBERS.txt"

birthday_doc = Path.home() / _FILE_PATH
lines = [line.strip() for line in birthday_doc.open()]

groups = groupby(lines, key=lambda val: len(val) > 0)

text_blocks = [list(val) for key, val in groups if key]

birthday_blocks = [block for block in text_blocks if len(block) > 1]

people = map(cast_block, birthday_blocks)

for person in people:
    print(f"{person.name}: {person.age()}")
