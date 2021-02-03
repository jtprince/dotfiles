#!/usr/bin/env python

# yay -S geckodriver
# pip install selenium bs4 tabulate lxml

import argparse
import datetime
import os
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Optional

from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from tabulate import tabulate

username = os.environ["POWERSCHOOL_USERNAME"]
password = os.environ["POWERSCHOOL_PASSWORD"]


@dataclass
class Grade:
    letter: str
    number: Optional[int]

    JUNK_BYTE = "\xa0"
    GRADE_RE = re.compile(r"([A-F][+-]?)(\d+)")

    @classmethod
    def from_str(cls, grade_chars_raw):
        grade_chars = grade_chars_raw.replace(cls.JUNK_BYTE, "")
        match = cls.GRADE_RE.match(grade_chars)
        number = None
        if match:
            letter, number = match.groups()
        elif grade_chars:
            letter = grade_chars
        else:
            letter = None
        return cls(letter=letter, number=number)

    def __str__(self):
        if self.number:
            return f"{self.letter:<2} {self.number}"
        else:
            return self.letter if self.letter else ""


@dataclass
class ClassOverview:
    name: str
    teacher: str
    room: str
    quarter_grades: list[Grade]
    absences: int
    tardies: int

    DETAILS_STR = "Details about "
    EMAIL_STR = " Email "
    ROOM_STR = "Rm: "
    JUNK_BYTE = "\xa0"

    SHORT_FIELDS = [
        "name",
        "q1",
        "q2",
        "q3",
        "q4",
        "absences",
        "tardies",
    ]

    def latest_quarter(self):
        """Returns the latest quarter, 1 indexed."""
        last_quarter_index = 0
        for cnt, grade in enumerate(self.quarter_grades):
            if grade.number or grade.letter:
                last_quarter_index = cnt
                break
        return last_quarter_index + 1

    @property
    def q1(self):
        return self.quarter_grades[0]

    @property
    def q2(self):
        return self.quarter_grades[1]

    @property
    def q3(self):
        return self.quarter_grades[2]

    @property
    def q4(self):
        return self.quarter_grades[3]

    @classmethod
    def many_from_html(cls, html):
        """Returns a list of ClassOverview objects."""
        soup = BeautifulSoup(html, "lxml")

        table = soup.find("table", {"class": "linkDescList grid"})
        rows = []
        for row in table.findAll("tr"):
            cells = row.findAll(["th", "td"])
            rows.append([cell.get_text() for cell in cells])

        rows = rows[3:-1]

        rows = [row[-7:] for row in rows]
        return [cls.from_html_text_cells(row) for row in rows]

    @classmethod
    def from_html_text_cells(cls, row: list):
        """Creats a ClassOverview from specific cols in the html table.

        Args:
            row: The last 7 text cells of the grade table.
        """
        classname, teacher_details, _, _, room_str = row[0].split(cls.JUNK_BYTE)
        teacher = teacher_details.replace(cls.DETAILS_STR, "")
        quarter_grades = [Grade.from_str(grade_text) for grade_text in row[1:5]]
        absences = int(row[-2])
        tardies = int(row[-1])
        room = room_str.removeprefix(cls.ROOM_STR)

        return cls(
            name=classname,
            teacher=teacher,
            room=room,
            quarter_grades=quarter_grades,
            absences=absences,
            tardies=tardies,
        )

    def to_dict(self, short=True):
        if short:
            data = {key: getattr(self, key) for key in self.SHORT_FIELDS}
            return {
                key: str(val) if isinstance(val, Grade) else val
                for key, val in data.items()
            }
        else:
            raise NotImplementedError("can't do not short!")


@dataclass
class Assignment:
    teacher: str
    course: str
    term: str
    due_date: datetime.date
    category: str
    assignment_name: str
    points_scored: Optional[float]
    points_possible: Optional[float]
    percent: Optional[float]
    letter_grade: str
    codes: str

    SHORT_FIELD_LENGTHS = dict(
        course=18,
        category=13,
    )

    SHORT_FIELDS = [
        "course",
        "due_date",
        "category",
        "assignment_name",
        "score",
    ]

    @property
    def score(self):
        return (
            f"{self.points_scored}/{self.points_possible}"
            if self.has_score()
            else None
        )

    @classmethod
    def many_from_html(cls, html):
        """Returns a list of Assignment objects."""
        soup = BeautifulSoup(html, "lxml")
        table = soup.find("table", {"class": "tablesorter grid"})
        rows = []
        for row in table.findAll("tr"):
            cells = row.findAll(["th", "td"])
            rows.append([cell.get_text() for cell in cells])

        return [cls.from_html_text_cells(row) for row in rows[1:]]

    @classmethod
    def from_html_text_cells(cls, row):
        (
            teacher,
            course,
            term,
            due_date,
            category,
            assignment_name,
            score,
            percent,
            letter_grade,
            codes,
        ) = [cell.strip() for cell in row]
        if "/" in score:
            points_scored, points_possible = list(map(float, score.split("/")))
        else:
            points_scored, points_possible = None, None
        month, day, year = list(map(int, due_date.split("/")))
        due_date = datetime.date(year, month, day)
        if "%" in percent:
            percent = float(percent.replace("%", ""))
        else:
            percent = None
        return cls(
            teacher=teacher,
            course=course,
            term=term,
            due_date=due_date,
            category=category,
            assignment_name=assignment_name,
            points_scored=points_scored,
            points_possible=points_possible,
            percent=percent,
            letter_grade=letter_grade,
            codes=codes,
        )

    def has_score(self):
        return self.percent is not None

    def coded_late(self):
        return "late" in self.codes.lower()

    def zero_and_past_due_date(self, today, days=0):
        days_diff = (today - self.due_date).days
        on_or_past_due_date = days_diff >= days
        return (self.points_scored == 0.0) and on_or_past_due_date

    def to_dict(self, short=False):
        if short:
            data = {key: getattr(self, key) for key in self.SHORT_FIELDS}
            for key, field_len in self.SHORT_FIELD_LENGTHS.items():
                data[key] = data[key][0:field_len]
        else:
            data = asdict(self)
        data["due_date"] = data["due_date"].isoformat()
        return data


class PowerschoolParser:
    SCHOOL_URL = "https://grades.provo.edu"
    LOGIN_URL = SCHOOL_URL + "/public/"
    ASSIGNMENTS_PAGE = SCHOOL_URL + "/guardian/classassignments.html"
    IMPLICIT_WAIT_SECONDS = 10
    _GRADES_AND_ATTENDANCE_PATH = Path("grades_and_attendance.html")
    _ASSIGNMENTS_FILENAME_FMT_STR = "assignments_for_quarter{}.html"

    def __init__(self, args):
        self.driver = None
        self.args = args

    def login(self):
        options = Options()
        options.headless = True
        self.driver = webdriver.Firefox(options=options)
        self.driver.implicitly_wait(self.IMPLICIT_WAIT_SECONDS)

        self.driver.get(self.LOGIN_URL)
        self.driver.find_element_by_id("fieldAccount").send_keys(username)
        self.driver.find_element_by_id("fieldPassword").send_keys(password)
        self.driver.find_element_by_id("btn-enter-sign-in").click()

    def _get_quarter_assignments_source(self, quarter):
        self.driver.get(self.ASSIGNMENTS_PAGE)
        tab = self.driver.find_element_by_link_text(f"Q{quarter}")
        tab.click()
        return self.driver.page_source

    def run(self, quarter=None):
        if args.read_cache and self._GRADES_AND_ATTENDANCE_PATH.exists():
            grades_and_attendance = self._GRADES_AND_ATTENDANCE_PATH.read_text()
        else:
            self.login()
            grades_and_attendance = self.driver.page_source
            if args.write_cache:
                self._GRADES_AND_ATTENDANCE_PATH.write_text(
                    grades_and_attendance
                )

        class_overviews = ClassOverview.many_from_html(grades_and_attendance)

        if quarter is None:
            quarter = max(
                overview.latest_quarter() for overview in class_overviews
            )

        quarter_assignment_path = Path(
            self._ASSIGNMENTS_FILENAME_FMT_STR.format(quarter)
        )
        if args.read_cache and quarter_assignment_path.exists():
            quarter_assignment_page = quarter_assignment_path.read_text()
        else:
            quarter_assignment_page = self._get_quarter_assignments_source(
                quarter
            )
            if args.write_cache:
                quarter_assignment_path.write_text(quarter_assignment_page)

        assignments = Assignment.many_from_html(quarter_assignment_page)
        return class_overviews, assignments


parser = argparse.ArgumentParser()
parser.add_argument(
    "--quarter", type=int, help="school quarter, otherwise will determine"
)
parser.add_argument(
    "--read-cache", action="store_true", help="read from any cached files"
)
parser.add_argument(
    "--write-cache", action="store_true", help="write cached files"
)
parser.add_argument("--format", default="simple", help="tabulate table format")

args = parser.parse_args()

class_overviews, assignments = PowerschoolParser(args=args).run()

today = datetime.date.today()


print("Assignments with no score past due date", end="\n\n")

table = tabulate(
    [
        assignment.to_dict(short=True)
        for assignment in assignments
        if assignment.zero_and_past_due_date(today)
    ],
    headers="keys",
    tablefmt=args.format,
)
print(table)
print()

print("Summary", end="\n\n")

data = [overview.to_dict(short=True) for overview in class_overviews]

table = tabulate(
    data,
    headers="keys",
    tablefmt=args.format,
)
print(table)
