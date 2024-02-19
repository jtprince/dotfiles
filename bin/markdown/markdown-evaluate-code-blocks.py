#!/usr/bin/env python

import argparse
import contextlib
import io
import traceback
from pathlib import Path

from mistune.markdown import Markdown
from mistune.renderers import AstRenderer


class CodeEvaluationRenderer(AstRenderer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.code_blocks = []

    def block_code(self, children, info=None):
        if "python" in (info or ""):
            self.code_blocks.append(str(children))


parser = argparse.ArgumentParser()
parser.add_argument("path", type=Path, help="the python file to test code blocks")
args = parser.parse_args()

renderer = CodeEvaluationRenderer()
markdown = Markdown(renderer=renderer)
markdown(args.path.read_text())

for block in renderer.code_blocks:
    try:
        captured_stdout = io.StringIO()
        captured_stderr = io.StringIO()
        with contextlib.redirect_stdout(captured_stdout):
            with contextlib.redirect_stderr(captured_stderr):
                exec(block, {})

        captured_stdout.seek(0)
        print(captured_stdout.read())

    except:  # noqa: E722
        banner = "=" * 8
        print(banner + " BLOCK " + banner)
        print(block)
        print(banner + " TRACE " + banner)
        traceback.print_exc()
