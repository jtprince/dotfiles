#!/usr/bin/env python3
"""
fantasy_tts_audiobook_cli.py

Single-file CLI tool for generating *high-quality* fantasy-novel TTS audiobooks using
only open-source tools.

Design goals
------------
- One CLI that can run the full pipeline (EPUB -> single M4B) via `all`.
- Subcommands expose each stage for iterative refinement.
- Preserves *all* intermediates by default with clear, disambiguating suffixes.
- Reminds the user how to install missing dependencies (brew + Arch/yay).
- Uses GPUs when available (Apple Silicon via `mlx` for Kokoro; CUDA if you swap engines).
- Clean, modular code; minimal duplication; avoid heavy error handling.

TTS Engine choice
-----------------
Default TTS engine is **Kokoro-82M** via `kokoro` + `mlx` on Apple Silicon.
This gives very strong quality, is open-source, and takes advantage of the M4 GPU.

Fallback engine is **Piper** (CPU, still very good). You can choose with --tts.

Text-prep quality boosters
--------------------------
Optional, high-leverage fantasy-narration improvements:
- `--pronounce pronunciations.csv`        (token -> replacement)
- `--pause-style off|neutral|fantasy|dramatic`
- `--dialogue-emphasis`                   (quoted-speech heuristics)

These are applied in the `prep` stage (clean -> prep) and integrated into `all`.
All intermediate files are preserved.

M4B creation
------------
Produces a single .m4b with chapters, cover art (optional), and metadata.
Metadata/cover is derived from the EPUB by default; CLI flags override.

Quickstart
----------
  ./fantasy_tts_audiobook_cli.py all book.epub

See `./fantasy_tts_audiobook_cli.py guide` for an end-to-end checklist.
"""

from __future__ import annotations

import argparse
import concurrent.futures as fut
import json
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple


# -----------------------------
# Install reminders (brew + yay)
# -----------------------------

_DEP: Dict[str, Dict[str, str]] = {
    "pandoc": {"brew": "brew install pandoc", "yay": "yay -S pandoc"},
    "ffmpeg": {"brew": "brew install ffmpeg", "yay": "yay -S ffmpeg"},
    "ffprobe": {"brew": "brew install ffmpeg", "yay": "yay -S ffmpeg"},
    "sox": {"brew": "brew install sox", "yay": "yay -S sox"},
    "lame": {"brew": "brew install lame", "yay": "yay -S lame"},
    "mp4box": {"brew": "brew install gpac", "yay": "yay -S gpac"},
    "python3": {"brew": "brew install python", "yay": "yay -S python"},
    "kokoro": {"pip": "python3 -m pip install -U kokoro"},
    "mlx": {"pip": "python3 -m pip install -U mlx"},
    "piper": {"brew": "brew install piper", "yay": "yay -S piper"},
}


# -----------------------------
# Small helpers
# -----------------------------


def _is_macos() -> bool:
    return platform.system().lower() == "darwin"


def _is_linux() -> bool:
    return platform.system().lower() == "linux"


def _shlex(cmds: Sequence[str]) -> str:
    return " ".join(shlex.quote(str(ccc)) for ccc in cmds)


def _run(
    cmds: Sequence[str],
    *,
    cwd: Optional[Path] = None,
    cap: bool = False,
) -> subprocess.CompletedProcess:
    """Run a command. Minimal error handling; raises on failure."""
    if cap:
        return subprocess.run(
            list(map(str, cmds)),
            cwd=str(cwd) if cwd else None,
            check=True,
            text=True,
            capture_output=True,
        )
    return subprocess.run(
        list(map(str, cmds)),
        cwd=str(cwd) if cwd else None,
        check=True,
    )


def _have_exe(nam: str) -> bool:
    return shutil.which(nam) is not None


def _have_py(mod: str) -> bool:
    try:
        __import__(mod)
        return True
    except Exception:
        return False


def _print_install(nam: str) -> None:
    inf = _DEP.get(nam, {})
    sys.stderr.write(f"\nMissing dependency: {nam}\n")
    if _is_macos() and "brew" in inf:
        sys.stderr.write(f"  macOS: {inf['brew']}\n")
    if _is_linux() and "yay" in inf:
        sys.stderr.write(f"  Arch:  {inf['yay']}\n")
    if "pip" in inf:
        sys.stderr.write(f"  pip:   {inf['pip']}\n")


def require_exes(*nms: str) -> None:
    mis: List[str] = []
    for nam in nms:
        if not _have_exe(nam):
            mis.append(nam)
    if mis:
        for nam in mis:
            _print_install(nam)
        raise SystemExit(2)


def require_py(*mods: str) -> None:
    mis: List[str] = []
    for mod in mods:
        if not _have_py(mod):
            mis.append(mod)
    if mis:
        for mod in mis:
            _print_install(mod)
        raise SystemExit(2)


# -----------------------------
# Naming scheme
# -----------------------------


@dataclass(frozen=True)
class BookId:
    src: Path
    out_dir: Path

    @property
    def stem(self) -> str:
        return self.src.stem

    def path(self, sfx: str, ext: str) -> Path:
        return self.out_dir / f"{self.stem}.{sfx}.{ext}"

    def chap_dir(self) -> Path:
        return self.out_dir / f"{self.stem}.chapters"

    def wav_dir(self) -> Path:
        return self.out_dir / f"{self.stem}.wav"

    def master_dir(self) -> Path:
        return self.out_dir / f"{self.stem}.master"


# -----------------------------
# Stage 0: EPUB metadata (title/author/cover)
# -----------------------------


@dataclass(frozen=True)
class MetaCfg:
    title: str
    author: str
    album: str
    cover: Optional[Path]


def read_epub_metadata_zip(bid: BookId) -> MetaCfg:
    """Read EPUB metadata + extract cover using only stdlib.

    - Opens the EPUB as a ZIP.
    - Uses META-INF/container.xml to find the OPF path.
    - Parses OPF for dc:title and dc:creator.
    - Finds the cover image using common EPUB2/EPUB3 patterns.
    - Extracts cover image to <stem>.cover.<ext> in out_dir.

    Raises on failure (caller can fall back).
    """
    import zipfile
    import xml.etree.ElementTree as ET

    def _xml_root(buf: bytes) -> ET.Element:
        return ET.fromstring(buf)

    def _ns_tag(tag: str) -> str:
        return tag.split("}")[-1] if "}" in tag else tag

    def _find_first(el: ET.Element, want: str) -> Optional[ET.Element]:
        for sub in el.iter():
            if _ns_tag(sub.tag) == want:
                return sub
        return None

    def _find_all(el: ET.Element, want: str) -> List[ET.Element]:
        out: List[ET.Element] = []
        for sub in el.iter():
            if _ns_tag(sub.tag) == want:
                out.append(sub)
        return out

    def _txt(el: Optional[ET.Element]) -> str:
        return (el.text or "").strip() if el is not None else ""

    def _ext_from_href(href: str) -> str:
        href = href.split("?")[0].split("#")[0]
        ext = Path(href).suffix.lower().lstrip(".")
        return ext or "jpg"

    with zipfile.ZipFile(bid.src, "r") as zzz:
        cont = zzz.read("META-INF/container.xml")
        root = _xml_root(cont)

        opf_path = ""
        for rf in root.iter():
            if _ns_tag(rf.tag) == "rootfile":
                opf_path = (rf.attrib.get("full-path") or "").strip()
                if opf_path:
                    break
        if not opf_path:
            raise RuntimeError("EPUB container.xml missing rootfile")

        opf_buf = zzz.read(opf_path)
        opf = _xml_root(opf_buf)

        ttl = _txt(_find_first(opf, "title")) or bid.stem

        creators = _find_all(opf, "creator")
        aut = ""
        if creators:
            aut = _txt(creators[0])
            for cre in creators:
                rol = (
                    cre.attrib.get("{http://www.idpf.org/2007/opf}role")
                    or cre.attrib.get("role")
                    or ""
                ).lower()
                if rol == "aut":
                    aut = _txt(cre)
                    break
        aut = aut or "Unknown"

        alb = ttl

        # Cover detection
        cover_id = ""
        for met in _find_all(opf, "meta"):
            nam = (met.attrib.get("name") or "").lower()
            if nam == "cover":
                cover_id = (met.attrib.get("content") or "").strip()
                if cover_id:
                    break

        manifest_items = _find_all(opf, "item")

        cover_href = ""
        cover_mime = ""

        if cover_id:
            for itm in manifest_items:
                if (itm.attrib.get("id") or "") == cover_id:
                    cover_href = (itm.attrib.get("href") or "").strip()
                    cover_mime = (itm.attrib.get("media-type") or "").strip()
                    break

        if not cover_href:
            for itm in manifest_items:
                props = (itm.attrib.get("properties") or "").lower()
                if "cover-image" in props:
                    cover_href = (itm.attrib.get("href") or "").strip()
                    cover_mime = (itm.attrib.get("media-type") or "").strip()
                    break

        if not cover_href:
            for itm in manifest_items:
                href = (itm.attrib.get("href") or "").lower()
                if "cover" in href and (
                    href.endswith(".jpg")
                    or href.endswith(".jpeg")
                    or href.endswith(".png")
                ):
                    cover_href = (itm.attrib.get("href") or "").strip()
                    cover_mime = (itm.attrib.get("media-type") or "").strip()
                    break

        cov_out: Optional[Path] = None
        if cover_href:
            opf_dir = str(Path(opf_path).parent)
            in_zip = (
                str(Path(opf_dir) / cover_href)
                if opf_dir not in (".", "")
                else cover_href
            )
            in_zip = in_zip.replace("\\", "/")

            try:
                cov_buf = zzz.read(in_zip)
                ext = _ext_from_href(cover_href)
                if cover_mime.endswith("png"):
                    ext = "png"
                elif cover_mime.endswith("jpeg") or cover_mime.endswith("jpg"):
                    ext = "jpg"

                cov_out = bid.path("cover", ext)
                cov_out.write_bytes(cov_buf)
            except KeyError:
                cov_out = None

        return MetaCfg(title=ttl, author=aut, album=alb, cover=cov_out)


def read_epub_metadata(
    bid: BookId,
    *,
    override_title: Optional[str] = None,
    override_author: Optional[str] = None,
    override_album: Optional[str] = None,
    override_cover: Optional[str] = None,
) -> MetaCfg:
    """Extract metadata + cover from an EPUB.

    Strategy (robust):
      1) Prefer EPUB-native OPF parsing from inside the ZIP.
      2) If that fails, *try* ffprobe tags as a fallback (best-effort).
      3) Never crash the pipeline for missing tags: use safe defaults.

    Overrides win if provided.
    """
    ttl = bid.stem
    aut = "Unknown"
    alb = ttl

    cov: Optional[Path] = (
        Path(override_cover).expanduser().resolve() if override_cover else None
    )

    try:
        met_opf = read_epub_metadata_zip(bid)
        ttl = met_opf.title or ttl
        aut = met_opf.author or aut
        alb = met_opf.album or alb
        if cov is None and met_opf.cover is not None:
            cov = met_opf.cover
    except Exception:
        pass

    if ttl == bid.stem and aut == "Unknown" and alb == ttl and _have_exe("ffprobe"):
        try:
            res = _run(
                [
                    "ffprobe",
                    "-v",
                    "error",
                    "-show_entries",
                    "format_tags=title,artist,album,composer,author",
                    "-of",
                    "json",
                    str(bid.src),
                ],
                cap=True,
            )
            dat = json.loads(res.stdout or "{}")
            tag = (dat.get("format", {}) or {}).get("tags", {}) or {}
            ttl = tag.get("title") or ttl
            aut = tag.get("artist") or tag.get("author") or tag.get("composer") or aut
            alb = tag.get("album") or alb
        except Exception:
            pass

    if override_title:
        ttl = override_title
    if override_author:
        aut = override_author
    if override_album:
        alb = override_album

    if cov is None and _have_exe("ffmpeg"):
        cov_try = bid.path("cover", "jpg")
        try:
            _run(
                [
                    "ffmpeg",
                    "-y",
                    "-i",
                    str(bid.src),
                    "-an",
                    "-vcodec",
                    "copy",
                    str(cov_try),
                ],
                cap=True,
            )
            if cov_try.exists() and cov_try.stat().st_size > 0:
                cov = cov_try
        except Exception:
            cov = None

    return MetaCfg(title=ttl, author=aut, album=alb, cover=cov)


# -----------------------------
# Stage 1: EPUB -> raw text
# -----------------------------


def epub_to_text(bid: BookId) -> Path:
    require_exes("pandoc")
    out_txt = bid.path("raw", "txt")
    _run(["pandoc", str(bid.src), "-t", "plain", "-o", str(out_txt)])
    return out_txt


# -----------------------------
# Stage 2: Cleanup + fantasy-friendly normalization
# -----------------------------

_FANTASY_SUBS: List[Tuple[re.Pattern, str]] = [
    (re.compile(r"\bMr\.", re.I), "Mister"),
    (re.compile(r"\bMrs\.", re.I), "Missus"),
    (re.compile(r"\bDr\.", re.I), "Doctor"),
    (re.compile(r"\bSt\.", re.I), "Saint"),
    (re.compile(r"\be\.g\.", re.I), "for example"),
    (re.compile(r"\bi\.e\.", re.I), "that is"),
    (re.compile(r"—"), ","),  # em dash -> comma (often reads better)
]


def clean_text(bid: BookId, inp: Path) -> Path:
    out_txt = bid.path("clean", "txt")
    txt = inp.read_text(encoding="utf-8", errors="ignore")

    txt = txt.replace("\r\n", "\n").replace("\r", "\n")
    txt = re.sub(r"[ \t]+", " ", txt)
    txt = re.sub(r"\n{3,}", "\n\n", txt)

    for pat, rep in _FANTASY_SUBS:
        txt = pat.sub(rep, txt)

    txt = re.sub(r"\s+([,.;:!?])", r"\1", txt)

    out_txt.write_text(txt.strip() + "\n", encoding="utf-8")
    return out_txt


# -----------------------------
# Stage 2b: Optional text prep (pronunciations, pause style, dialogue emphasis)
# -----------------------------


@dataclass(frozen=True)
class PrepCfg:
    pronounce: Optional[Path]
    pause_style: str  # off|neutral|fantasy|dramatic
    dialogue_emphasis: bool


def apply_pronunciations(txt: str, csv_path: Path) -> str:
    """Apply token -> replacement rules from a CSV file.

    CSV format:
      token,replace
      Aelin,AY-lin

    - Longest-token-first ordering.
    - Literal string replacements.
    """
    import csv

    rows: List[Tuple[str, str]] = []
    with csv_path.open("r", encoding="utf-8", errors="ignore", newline="") as fff:
        rdr = csv.DictReader(fff)
        for row in rdr:
            tkn = (row.get("token") or "").strip()
            rep = (row.get("replace") or "").strip()
            if tkn and rep:
                rows.append((tkn, rep))

    rows.sort(key=lambda rr: len(rr[0]), reverse=True)
    for tkn, rep in rows:
        txt = txt.replace(tkn, rep)
    return txt


_PAUSE_MS = {
    "neutral": {
        "para": 350,
        "chap": 800,
        "semi": 120,
        "ellipsis": 200,
        "quote_end": 120,
        "dash": 120,
    },
    "fantasy": {
        "para": 450,
        "chap": 950,
        "semi": 150,
        "ellipsis": 250,
        "quote_end": 180,
        "dash": 180,
    },
    "dramatic": {
        "para": 600,
        "chap": 1200,
        "semi": 200,
        "ellipsis": 350,
        "quote_end": 250,
        "dash": 250,
    },
}


def inject_pauses(txt: str, style: str) -> str:
    """Insert lightweight pause markers to influence TTS pacing."""
    if style == "off" or style not in _PAUSE_MS:
        return txt

    prm = _PAUSE_MS[style]
    pau_para = f"[[PAUSE_{prm['para']}]]"
    pau_semi = f"[[PAUSE_{prm['semi']}]]"
    pau_ell = f"[[PAUSE_{prm['ellipsis']}]]"
    pau_dsh = f"[[PAUSE_{prm['dash']}]]"

    txt = re.sub(r"\n\n+", f"\n\n{pau_para}\n\n", txt)
    txt = txt.replace(";", f"; {pau_semi}")
    txt = txt.replace("...", f"... {pau_ell}")
    txt = txt.replace("—", f", {pau_dsh}")
    return txt


_SPEECH_TAG = re.compile(
    r'(?i)([“"])(.+?)([”"])'
    r"\s*,\s*(he|she|they|i|we|you)\s+"
    r"(said|asked|whispered|muttered|shouted|yelled|hissed|growled|snapped|replied|cried)\b"
)


def enhance_dialogue(txt: str, style: str) -> str:
    """Heuristic dialogue improvements.

    Adds a small pause after quoted dialogue when followed by a speech tag.
    Keeps changes punctuation-based so it works across engines.
    """
    prm = _PAUSE_MS.get(style, _PAUSE_MS["neutral"])
    qpa = f"[[PAUSE_{prm['quote_end']}]]"

    def _repl(mat: re.Match) -> str:
        pfx, bod, sfx, subj, vbb = (
            mat.group(1),
            mat.group(2),
            mat.group(3),
            mat.group(4),
            mat.group(5),
        )
        bod = bod.strip()
        if bod and bod[-1] not in ".!?…":
            bod = bod + "."
        return f"{pfx}{bod}{sfx} {qpa} {subj} {vbb}"

    return _SPEECH_TAG.sub(_repl, txt)


def render_pause_tokens(txt: str) -> str:
    """Convert [[PAUSE_###]] tokens into punctuation/newlines."""

    def _rep(mat: re.Match) -> str:
        ms = int(mat.group(1))
        if ms >= 800:
            return "\n\n"
        if ms >= 350:
            return "\n"
        if ms >= 200:
            return "..."
        return ","

    return re.sub(r"\[\[PAUSE_(\d+)\]\]", _rep, txt)


def prepare_text(bid: BookId, inp: Path, cfg: PrepCfg) -> Path:
    """Apply optional transforms and preserve intermediates."""
    txt = inp.read_text(encoding="utf-8", errors="ignore")
    cur = txt

    if cfg.pronounce is not None:
        cur = apply_pronunciations(cur, cfg.pronounce)
        bid.path("pronounce", "txt").write_text(cur, encoding="utf-8")

    if cfg.pause_style != "off":
        cur = inject_pauses(cur, cfg.pause_style)
        bid.path(f"pause_{cfg.pause_style}", "txt").write_text(cur, encoding="utf-8")

    if cfg.dialogue_emphasis:
        sty = cfg.pause_style if cfg.pause_style != "off" else "neutral"
        cur = enhance_dialogue(cur, sty)
        bid.path(f"dialogue_{sty}", "txt").write_text(cur, encoding="utf-8")

    cur = render_pause_tokens(cur)

    out = bid.path("prep", "txt")
    out.write_text(cur.strip() + "\n", encoding="utf-8")
    return out


# -----------------------------
# Stage 3: Chapter split
# -----------------------------

_CHAP_PAT = re.compile(
    r"(?m)^(chapter\s+\d+|chapter\s+[ivxlcdm]+|prologue|epilogue)\b.*$",
    re.I,
)


def split_chapters(bid: BookId, inp: Path) -> List[Path]:
    chd = bid.chap_dir()
    chd.mkdir(parents=True, exist_ok=True)

    txt = inp.read_text(encoding="utf-8", errors="ignore")
    hits = list(_CHAP_PAT.finditer(txt))

    if not hits:
        out = chd / f"{bid.stem}.chapter01.txt"
        out.write_text(txt, encoding="utf-8")
        return [out]

    out_paths: List[Path] = []
    for idx, mat in enumerate(hits):
        sta = mat.start()
        end = hits[idx + 1].start() if idx + 1 < len(hits) else len(txt)
        ttl = mat.group(0).strip()
        bdy = txt[sta:end].strip()

        num = idx + 1
        out = chd / f"{bid.stem}.chapter{num:02d}.txt"
        out.write_text(ttl + "\n\n" + bdy + "\n", encoding="utf-8")
        out_paths.append(out)

    man = bid.path("chapters", "json")
    man.write_text(
        json.dumps(
            [
                {"index": ii + 1, "file": str(pp), "title": _first_line(pp)}
                for ii, pp in enumerate(out_paths)
            ],
            indent=2,
        ),
        encoding="utf-8",
    )

    return out_paths


def _first_line(ppp: Path) -> str:
    try:
        return ppp.read_text(encoding="utf-8", errors="ignore").splitlines()[0].strip()
    except Exception:
        return ppp.stem


# -----------------------------
# Stage 4: TTS render (Kokoro/MLX or Piper)
# -----------------------------


@dataclass(frozen=True)
class TtsCfg:
    tts: str  # kokoro|piper
    voice: str
    rate: float
    jobs: int


def _tts_kokoro_one(txt: Path, wav: Path, cfg: TtsCfg) -> None:
    require_py("kokoro", "mlx")

    def normalize_kokoro_voice(vvv: str) -> str:
        alias = {
            "af": "af_heart",
            "bf": "bf_emma",
            "jf": "jf_sakura",
        }
        return alias.get(vvv, vvv)

    voi = normalize_kokoro_voice(cfg.voice)

    cmd = [
        sys.executable,
        "-m",
        "kokoro",
        "-m",
        voi,
        "-s",
        str(cfg.rate),
        "-i",
        str(txt),
        "-o",
        str(wav),
    ]
    _run(cmd)


def _tts_piper_one(txt: Path, wav: Path, mdl: Path) -> None:
    require_exes("piper")
    cmd = ["piper", "--model", str(mdl), "--output_file", str(wav)]
    dat = txt.read_text(encoding="utf-8", errors="ignore")
    subprocess.run(cmd, input=dat, text=True, check=True)


def render_tts(
    bid: BookId,
    chp: List[Path],
    cfg: TtsCfg,
    *,
    piper_model: Optional[Path] = None,
) -> List[Path]:
    wav_dir = bid.wav_dir()
    wav_dir.mkdir(parents=True, exist_ok=True)

    def one(inp: Path) -> Path:
        wav = wav_dir / (inp.stem + ".raw.wav")
        if cfg.tts == "kokoro":
            _tts_kokoro_one(inp, wav, cfg)
        else:
            if piper_model is None:
                raise SystemExit("--piper-model is required when --tts=piper")
            _tts_piper_one(inp, wav, piper_model)
        return wav

    with fut.ThreadPoolExecutor(max_workers=cfg.jobs) as exe:
        return list(exe.map(one, chp))


# -----------------------------
# Stage 5: Audio post-processing + mastering per chapter
# -----------------------------


@dataclass(frozen=True)
class AudCfg:
    rate: int
    lufs: float
    tpdb: float
    lrar: float


def process_audio(bid: BookId, wavs: List[Path], cfg: AudCfg) -> List[Path]:
    require_exes("ffmpeg")
    out_dir = bid.master_dir()
    out_dir.mkdir(parents=True, exist_ok=True)

    afx = (
        "highpass=f=70,"
        "equalizer=f=3500:t=q:w=1:g=-2,"
        "equalizer=f=8000:t=q:w=1:g=-1,"
        "acompressor=threshold=-18dB:ratio=2:attack=5:release=100:makeup=3,"
        f"loudnorm=I={cfg.lufs}:TP={cfg.tpdb}:LRA={cfg.lrar}"
    )

    out: List[Path] = []
    for inp in wavs:
        mid = out_dir / (inp.stem.replace(".raw", "") + f".sr{cfg.rate}.wav")
        fin = out_dir / (inp.stem.replace(".raw", "") + ".master.wav")

        _run(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(inp),
                "-ac",
                "1",
                "-ar",
                str(cfg.rate),
                "-sample_fmt",
                "s32",
                str(mid),
            ]
        )
        _run(["ffmpeg", "-y", "-i", str(mid), "-af", afx, str(fin)])
        out.append(fin)

    return out


# -----------------------------
# Stage 6: Join chapters -> single M4B with chapter metadata
# -----------------------------


def _ff_concat_list(lst: List[Path], out: Path) -> Path:
    pth = out.with_suffix(out.suffix + ".concat.txt")
    pth.write_text(
        "\n".join(f"file '{pp.as_posix()}'" for pp in lst) + "\n", encoding="utf-8"
    )
    return pth


def _chapters_ffmeta(chp: List[Path], wavs: List[Path], out: Path) -> Path:
    """Create FFmetadata file with chapter times from per-chapter durations."""
    require_exes("ffprobe")

    durs: List[float] = []
    for wav in wavs:
        res = _run(
            [
                "ffprobe",
                "-v",
                "error",
                "-show_entries",
                "format=duration",
                "-of",
                "default=noprint_wrappers=1:nokey=1",
                str(wav),
            ],
            cap=True,
        )
        durs.append(float((res.stdout or "0").strip() or 0))

    tms = 0
    lns = [";FFMETADATA1"]
    for txt, sec in zip(chp, durs):
        ttl = _first_line(txt)
        sta = tms
        end = tms + int(sec * 1000)
        tms = end
        lns.extend(
            [
                "[CHAPTER]",
                "TIMEBASE=1/1000",
                f"START={sta}",
                f"END={end}",
                f"title={ttl}",
            ]
        )

    out.write_text("\n".join(lns) + "\n", encoding="utf-8")
    return out


def make_m4b(bid: BookId, chp: List[Path], wavs: List[Path], cfg: MetaCfg) -> Path:
    require_exes("ffmpeg", "ffprobe")

    out_m4b = bid.path("final", "m4b")

    con_lst = _ff_concat_list(wavs, bid.path("master", "wav"))
    big_wav = bid.path("joined", "wav")
    _run(
        [
            "ffmpeg",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(con_lst),
            "-c",
            "copy",
            str(big_wav),
        ]
    )

    meta = _chapters_ffmeta(chp, wavs, bid.path("chapters", "ffmeta"))

    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        str(big_wav),
        "-i",
        str(meta),
        "-map_metadata",
        "1",
        "-metadata",
        f"title={cfg.title}",
        "-metadata",
        f"artist={cfg.author}",
        "-metadata",
        f"album={cfg.album}",
        "-c:a",
        "aac",
        "-b:a",
        "96k",
    ]

    if cfg.cover is not None:
        cmd.extend(
            [
                "-i",
                str(cfg.cover),
                "-map",
                "0:a",
                "-map",
                "2:v",
                "-c:v",
                "jpeg",
                "-disposition:v",
                "attached_pic",
            ]
        )

    cmd.append(str(out_m4b))
    _run(cmd)

    return out_m4b


# -----------------------------
# Guide / UX helpers
# -----------------------------

_GUIDE = r"""
Fantasy TTS Audiobook: High Quality Open-Source Checklist

0) Dependencies (one-time)
   macOS:  brew install pandoc ffmpeg sox lame gpac
   Arch:   yay -S pandoc ffmpeg sox lame gpac

   TTS (choose one):
     - Kokoro (best on Apple Silicon):
         pip install -U kokoro mlx
     - Piper (simple CPU):
         macOS: brew install piper
         Arch:  yay -S piper

1) Run full pipeline (EPUB -> single .m4b)
   ./fantasy_tts_audiobook_cli.py all book.epub

   With fantasy boosts:
   ./fantasy_tts_audiobook_cli.py all book.epub \
       --pronounce pronunciations.csv \
       --pause-style fantasy \
       --dialogue-emphasis

2) Outputs
   - Raw text:         <stem>.raw.txt
   - Clean text:       <stem>.clean.txt
   - Prepared text:    <stem>.prep.txt
   - Chapters:         <stem>.chapters/*.txt
   - TTS wavs:         <stem>.wav/*.raw.wav
   - Mastered wavs:    <stem>.master/*.master.wav
   - Final M4B:        <stem>.final.m4b
"""


def cmd_guide(_: argparse.Namespace) -> None:
    sys.stdout.write(_GUIDE.strip() + "\n")


def cmd_meta(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)

    met = read_epub_metadata(
        bid,
        override_title=arg.title,
        override_author=arg.author,
        override_album=arg.album,
        override_cover=arg.cover,
    )

    dat = {
        "src": str(bid.src),
        "title": met.title,
        "author": met.author,
        "album": met.album,
        "cover": str(met.cover) if met.cover else None,
    }
    sys.stdout.write(json.dumps(dat, indent=2) + "\n")


def cmd_text(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    out_txt = epub_to_text(bid)
    sys.stdout.write(str(out_txt) + "\n")


def cmd_clean(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    inp = Path(arg.inp).expanduser().resolve()
    out_txt = clean_text(bid, inp)
    sys.stdout.write(str(out_txt) + "\n")


def cmd_prep(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    inp = Path(arg.inp).expanduser().resolve()
    cfg = PrepCfg(
        pronounce=Path(arg.pronounce).expanduser().resolve() if arg.pronounce else None,
        pause_style=arg.pause_style,
        dialogue_emphasis=arg.dialogue_emphasis,
    )
    out_txt = prepare_text(bid, inp, cfg)
    sys.stdout.write(str(out_txt) + "\n")


def cmd_split(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    inp = Path(arg.inp).expanduser().resolve()
    out = split_chapters(bid, inp)
    sys.stdout.write("\n".join(map(str, out)) + "\n")


def cmd_tts(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    chp = [Path(pp).expanduser().resolve() for pp in arg.chapters]
    cfg = TtsCfg(tts=arg.tts, voice=arg.voice, rate=arg.rate, jobs=arg.jobs)
    mdl = Path(arg.piper_model).expanduser().resolve() if arg.piper_model else None
    out = render_tts(bid, chp, cfg, piper_model=mdl)
    sys.stdout.write("\n".join(map(str, out)) + "\n")


def cmd_master(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    wavs = [Path(pp).expanduser().resolve() for pp in arg.wavs]
    cfg = AudCfg(rate=arg.sr, lufs=arg.lufs, tpdb=arg.tp, lrar=arg.lra)
    out = process_audio(bid, wavs, cfg)
    sys.stdout.write("\n".join(map(str, out)) + "\n")


def cmd_m4b(arg: argparse.Namespace) -> None:
    bid = BookId(
        src=Path(arg.src).expanduser().resolve(),
        out_dir=Path(arg.out).expanduser().resolve(),
    )
    bid.out_dir.mkdir(parents=True, exist_ok=True)
    chp = [Path(pp).expanduser().resolve() for pp in arg.chapters]
    wavs = [Path(pp).expanduser().resolve() for pp in arg.wavs]
    met = read_epub_metadata(
        bid,
        override_title=arg.title,
        override_author=arg.author,
        override_album=arg.album,
        override_cover=arg.cover,
    )
    out = make_m4b(bid, chp, wavs, met)
    sys.stdout.write(str(out) + "\n")


def cmd_all(arg: argparse.Namespace) -> None:
    src = Path(arg.src).expanduser().resolve()
    out_dir = Path(arg.out).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    bid = BookId(src=src, out_dir=out_dir)

    met = read_epub_metadata(
        bid,
        override_title=arg.title,
        override_author=arg.author,
        override_album=arg.album,
        override_cover=arg.cover,
    )

    raw_txt = epub_to_text(bid)
    cln_txt = clean_text(bid, raw_txt)

    prp_cfg = PrepCfg(
        pronounce=Path(arg.pronounce).expanduser().resolve() if arg.pronounce else None,
        pause_style=arg.pause_style,
        dialogue_emphasis=arg.dialogue_emphasis,
    )
    prp_txt = prepare_text(bid, cln_txt, prp_cfg)

    chp_txt = split_chapters(bid, prp_txt)

    tts_cfg = TtsCfg(tts=arg.tts, voice=arg.voice, rate=arg.rate, jobs=arg.jobs)
    mdl = Path(arg.piper_model).expanduser().resolve() if arg.piper_model else None
    raw_wav = render_tts(bid, chp_txt, tts_cfg, piper_model=mdl)

    aud_cfg = AudCfg(rate=arg.sr, lufs=arg.lufs, tpdb=arg.tp, lrar=arg.lra)
    mas_wav = process_audio(bid, raw_wav, aud_cfg)

    out_m4b = make_m4b(bid, chp_txt, mas_wav, met)
    sys.stdout.write(str(out_m4b) + "\n")


# -----------------------------
# Argparse
# -----------------------------


def _add_common_io(par: argparse.ArgumentParser) -> None:
    par.add_argument(
        "--out", default=".", help="Output directory (default: current directory)."
    )


def _add_common_meta(par: argparse.ArgumentParser) -> None:
    par.add_argument(
        "--title", default=None, help="Override book title (otherwise read from EPUB)."
    )
    par.add_argument(
        "--author",
        default=None,
        help="Override author/narrator (otherwise read from EPUB).",
    )
    par.add_argument(
        "--album", default=None, help="Override album (otherwise EPUB title)."
    )
    par.add_argument(
        "--cover",
        default=None,
        help="Override cover image path (otherwise extracted from EPUB).",
    )


def _add_common_tts(par: argparse.ArgumentParser) -> None:
    par.add_argument(
        "--tts",
        default="kokoro",
        choices=["kokoro", "piper"],
        help="TTS engine: kokoro (Apple GPU via mlx) or piper (CPU).",
    )
    par.add_argument("--voice", default="af_heart", help="Voice id (engine-specific).")
    par.add_argument("--rate", type=float, default=1.0, help="Speech speed multiplier.")
    par.add_argument(
        "--jobs",
        type=int,
        default=max(2, (os.cpu_count() or 4) // 2),
        help="Parallel chapter jobs.",
    )
    par.add_argument(
        "--piper-model",
        default=None,
        help="Path to Piper .onnx model if using --tts=piper",
    )


def _add_common_audio(par: argparse.ArgumentParser) -> None:
    par.add_argument("--sr", type=int, default=48000, help="Sample rate for mastering.")
    par.add_argument(
        "--lufs", type=float, default=-18.0, help="Target integrated loudness LUFS."
    )
    par.add_argument("--tp", type=float, default=-3.0, help="True peak ceiling dBTP.")
    par.add_argument("--lra", type=float, default=9.0, help="Target loudness range.")


def _add_common_prep(par: argparse.ArgumentParser) -> None:
    par.add_argument(
        "--pronounce", default=None, help="Pronunciation CSV (token,replace)."
    )
    par.add_argument(
        "--pause-style",
        default="fantasy",
        choices=["off", "neutral", "fantasy", "dramatic"],
        help="Pause style preset.",
    )
    par.add_argument(
        "--dialogue-emphasis",
        action="store_true",
        help="Improve dialogue cadence with simple heuristics.",
    )


def build_cli() -> argparse.ArgumentParser:
    par = argparse.ArgumentParser(
        prog="fantasy-tts",
        description="High-quality fantasy TTS audiobook builder (EPUB -> M4B) using open-source tools.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    sub = par.add_subparsers(dest="cmd", required=True)

    ggg = sub.add_parser(
        "guide", help="Print an end-to-end checklist for the workflow."
    )
    ggg.set_defaults(func=cmd_guide)

    mmm = sub.add_parser(
        "meta", help="Print EPUB-derived metadata (with optional overrides)."
    )
    mmm.add_argument("src", help="Input EPUB path.")
    _add_common_io(mmm)
    _add_common_meta(mmm)
    mmm.set_defaults(func=cmd_meta)

    ttt = sub.add_parser("text", help="Convert EPUB -> raw plain text.")
    ttt.add_argument("src", help="Input EPUB path.")
    _add_common_io(ttt)
    ttt.set_defaults(func=cmd_text)

    cll = sub.add_parser(
        "clean", help="Clean/normalize raw text for fantasy narration."
    )
    cll.add_argument("src", help="Original EPUB path (used for naming).")
    cll.add_argument("inp", help="Input .txt path.")
    _add_common_io(cll)
    cll.set_defaults(func=cmd_clean)

    prp = sub.add_parser(
        "prep",
        help="Apply pronunciations + pause style + dialogue emphasis to cleaned text.",
    )
    prp.add_argument("src", help="Original EPUB path (used for naming).")
    prp.add_argument("inp", help="Input cleaned .txt path.")
    _add_common_io(prp)
    _add_common_prep(prp)
    prp.set_defaults(func=cmd_prep)

    sss = sub.add_parser("split", help="Split prepared text into chapter .txt files.")
    sss.add_argument("src", help="Original EPUB path (used for naming).")
    sss.add_argument("inp", help="Input prepared .txt path.")
    _add_common_io(sss)
    sss.set_defaults(func=cmd_split)

    tts = sub.add_parser(
        "tts", help="Render chapter .txt files to per-chapter WAV using TTS."
    )
    tts.add_argument("src", help="Original EPUB path (used for naming).")
    tts.add_argument("chapters", nargs="+", help="Chapter .txt paths.")
    _add_common_io(tts)
    _add_common_tts(tts)
    tts.set_defaults(func=cmd_tts)

    mas = sub.add_parser("master", help="Post-process + master per-chapter WAVs.")
    mas.add_argument("src", help="Original EPUB path (used for naming).")
    mas.add_argument("wavs", nargs="+", help="Per-chapter raw WAV paths.")
    _add_common_io(mas)
    _add_common_audio(mas)
    mas.set_defaults(func=cmd_master)

    m4b = sub.add_parser(
        "m4b", help="Join mastered WAVs into a single M4B with chapters."
    )
    m4b.add_argument("src", help="Original EPUB path (used for naming + metadata).")
    m4b.add_argument("chapters", nargs="+", help="Chapter .txt paths (for titles).")
    m4b.add_argument(
        "--wavs", nargs="+", required=True, help="Mastered per-chapter WAV paths."
    )
    _add_common_io(m4b)
    _add_common_meta(m4b)
    m4b.set_defaults(func=cmd_m4b)

    allp = sub.add_parser(
        "all", help="Run EPUB -> clean -> prep -> split -> TTS -> master -> single M4B."
    )
    allp.add_argument("src", help="Input EPUB path.")
    _add_common_io(allp)
    _add_common_meta(allp)
    _add_common_prep(allp)
    _add_common_tts(allp)
    _add_common_audio(allp)
    allp.set_defaults(func=cmd_all)

    return par


def main(argv: Optional[Sequence[str]] = None) -> None:
    par = build_cli()
    arg = par.parse_args(argv)
    arg.func(arg)


if __name__ == "__main__":
    main()
