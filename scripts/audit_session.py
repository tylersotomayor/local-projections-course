#!/usr/bin/env python3
"""Run fast structural checks for one course session.

This does not replace rendering or visual review. It catches the bookkeeping
errors that are easiest to introduce while several outputs share one source:
orphaned glossary terms, incomplete exercise apparatus, missing cross-reference
targets, and unpaired figure assets.
"""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from pathlib import Path
import re
import sys


REQUIRED_FILES = (
    "_body.qmd",
    "notes.qmd",
    "exercises.qmd",
    "glossary.qmd",
    "solutions.qmd",
    "slides.qmd",
    "references.bib",
)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def attribute_keys(text: str, class_name: str) -> list[str]:
    keys: list[str] = []
    for attributes in re.findall(r"\{([^{}]*)\}", text):
        if f".{class_name}" not in attributes:
            continue
        match = re.search(r'data-term\s*=\s*"([^"]+)"', attributes)
        if match:
            keys.append(match.group(1))
    return keys


def attribute_count(text: str, class_name: str) -> int:
    return sum(
        f".{class_name}" in attributes
        for attributes in re.findall(r"\{([^{}]*)\}", text)
    )


def duplicate_values(values: list[str]) -> list[str]:
    return sorted(value for value, count in Counter(values).items() if count > 1)


def labels_in(text: str) -> list[str]:
    return re.findall(r"\{[^{}]*#([A-Za-z][A-Za-z0-9_-]*)[^{}]*\}", text)


def references_in(text: str) -> set[str]:
    quarto = set(re.findall(r"@((?:eq|fig|tbl|sec)-[A-Za-z0-9_-]+)", text))
    anchors = set(
        re.findall(
            r"\(#((?:assumption|exercise|sec)-[A-Za-z0-9_-]+)\)", text
        )
    )
    return quarto | anchors


def count_heading(text: str, level: int) -> int:
    marker = "#" * level
    return len(re.findall(rf"^{re.escape(marker)}\s+", text, flags=re.MULTILINE))


def main_section_count(text: str) -> int:
    count = 0
    for line in text.splitlines():
        if not line.startswith("## "):
            continue
        if ".unnumbered" in line or "#sec-" not in line:
            continue
        count += 1
    return count


def resolve_repo_path(repo_root: Path, source_path: str) -> Path:
    if source_path.startswith("/"):
        return repo_root / source_path.lstrip("/")
    return repo_root / source_path


def audit(session_dir: Path, playground: Path | None) -> int:
    repo_root = Path(__file__).resolve().parents[1]
    errors: list[str] = []
    warnings: list[str] = []
    passes: list[str] = []

    missing_required = [name for name in REQUIRED_FILES if not (session_dir / name).is_file()]
    if missing_required:
        errors.append("missing required files: " + ", ".join(missing_required))
        print_report(session_dir, errors, warnings, passes, {})
        return 1
    passes.append("all required session source files are present")

    body = read(session_dir / "_body.qmd")
    notes = read(session_dir / "notes.qmd")
    exercises = read(session_dir / "exercises.qmd")
    glossary = read(session_dir / "glossary.qmd")
    solutions = read(session_dir / "solutions.qmd")
    slides = read(session_dir / "slides.qmd")
    chapter_sources = "\n".join((body, exercises, glossary))

    if "_body.qmd" not in notes:
        errors.append("notes.qmd does not include _body.qmd")
    if "exercises.qmd" not in body:
        errors.append("_body.qmd does not include exercises.qmd")
    if "glossary.qmd" not in body:
        errors.append("_body.qmd does not include glossary.qmd")
    if "exercises.qmd" not in solutions:
        errors.append("solutions.qmd does not include exercises.qmd")
    if not any("include" in item for item in errors):
        passes.append("shared body, exercise, glossary, and solution includes are wired")

    glossary_uses = attribute_keys(body, "glossary-term")
    glossary_heads = attribute_keys(glossary, "glossary-head")
    glossary_labels = re.findall(
        r"^\[([^\]]+)\]\{[^}\n]*\.glossary-head[^}\n]*\}",
        glossary,
        flags=re.MULTILINE,
    )
    duplicate_uses = duplicate_values(glossary_uses)
    duplicate_heads = duplicate_values(glossary_heads)
    undefined_terms = sorted(set(glossary_uses) - set(glossary_heads))
    unused_definitions = sorted(set(glossary_heads) - set(glossary_uses))

    if duplicate_uses:
        errors.append("glossary terms marked more than once: " + ", ".join(duplicate_uses))
    if duplicate_heads:
        errors.append("duplicate glossary definitions: " + ", ".join(duplicate_heads))
    if undefined_terms:
        errors.append("glossary terms without definitions: " + ", ".join(undefined_terms))
    if unused_definitions:
        errors.append("glossary definitions without marked uses: " + ", ".join(unused_definitions))
    if not (duplicate_uses or duplicate_heads or undefined_terms or unused_definitions):
        passes.append(f"{len(glossary_heads)} glossary uses and definitions match one for one")
    if glossary_labels != sorted(glossary_labels, key=str.casefold):
        errors.append("glossary entries are not alphabetized by displayed term")
    else:
        passes.append("glossary entries are alphabetized")

    exercise_titles = re.findall(r"^###\s+Exercise\s+\d+:", exercises, flags=re.MULTILINE)
    exercise_ids = re.findall(r"#exercise-[A-Za-z0-9_-]+", exercises)
    hint_count = len(re.findall(r"\.exercise-hint\b", exercises))
    solution_count = len(re.findall(r"\.exercise-solution\b", exercises))
    exercise_count = len(exercise_titles)
    if len(set(exercise_ids)) != exercise_count:
        errors.append(
            f"exercise IDs are not one-to-one with exercises "
            f"({len(set(exercise_ids))} unique IDs for {exercise_count} exercises)"
        )
    if hint_count != exercise_count:
        errors.append(f"found {hint_count} hints for {exercise_count} exercises")
    if solution_count != exercise_count:
        errors.append(f"found {solution_count} detailed solutions for {exercise_count} exercises")
    if len(set(exercise_ids)) == exercise_count == hint_count == solution_count:
        passes.append(f"all {exercise_count} exercises have one ID, hint, and detailed solution")

    all_labels = labels_in(chapter_sources)
    duplicate_labels = duplicate_values(all_labels)
    all_references = references_in(chapter_sources)
    missing_targets = sorted(all_references - set(all_labels))
    if duplicate_labels:
        errors.append("duplicate cross-reference labels: " + ", ".join(duplicate_labels))
    if missing_targets:
        errors.append("cross-references without explicit targets: " + ", ".join(missing_targets))
    if not duplicate_labels and not missing_targets:
        passes.append(f"{len(all_references)} explicit cross-references resolve to unique targets")

    asset_extensions: dict[str, set[str]] = defaultdict(set)
    asset_paths: list[tuple[str, str]] = []
    asset_pattern = re.compile(
        r"\((/lectures/[^)\s]+/figures/(fig-[A-Za-z0-9_-]+)\.(svg|pdf))\)"
    )
    for match in asset_pattern.finditer(body):
        source_path, stem, extension = match.groups()
        asset_extensions[stem].add(extension)
        asset_paths.append((source_path, extension))

    for stem, extensions in sorted(asset_extensions.items()):
        missing_extensions = {"svg", "pdf"} - extensions
        if missing_extensions:
            errors.append(
                f"figure {stem} lacks a referenced " + ", ".join(sorted(missing_extensions)) + " version"
            )

    for source_path, _extension in asset_paths:
        if not resolve_repo_path(repo_root, source_path).is_file():
            errors.append(f"referenced figure asset does not exist: {source_path}")

    svg_lines = [line for line in body.splitlines() if ".svg)" in line and line.lstrip().startswith("![")]
    missing_alt = [line.strip() for line in svg_lines if "fig-alt=" not in line]
    if missing_alt:
        errors.append(f"{len(missing_alt)} SVG figure reference(s) lack fig-alt text")

    if asset_extensions and not any("figure" in item for item in errors):
        passes.append(f"all {len(asset_extensions)} teaching figures have SVG, PDF, and web alt text")

    footnote_count = attribute_count(body, "footnote-term")
    slide_count = count_heading(slides, 2) + 1
    snapshot: dict[str, int | str] = {
        "main sections": main_section_count(body),
        "subsections": count_heading(body, 3),
        "equation labels": len(set(label for label in all_labels if label.startswith("eq-"))),
        "figure labels": len(set(label for label in all_labels if label.startswith("fig-"))),
        "table labels": len(set(label for label in all_labels if label.startswith("tbl-"))),
        "glossary terms": len(glossary_heads),
        "footnote terms": footnote_count,
        "exercises": exercise_count,
        "slides including title": slide_count,
    }

    if playground is not None:
        if not playground.is_file():
            errors.append(f"playground does not exist: {playground}")
        else:
            playground_text = read(playground)
            prediction_count = len(re.findall(r"Predict before", playground_text, flags=re.IGNORECASE))
            control_count = len(
                re.findall(
                    r"viewof\s+[A-Za-z0-9_]+\s*=\s*Inputs\."
                    r"(?:range|select|toggle|checkbox|radio|text|number|date|button)",
                    playground_text,
                )
            )
            explanation_count = len(
                re.findall(r"\.callout-[A-Za-z]+[^}\n]*collapse=\"true\"", playground_text)
            )
            snapshot["playground prediction prompts"] = prediction_count
            snapshot["playground controls"] = control_count
            snapshot["playground collapsed explanations"] = explanation_count
            if prediction_count == 0:
                warnings.append("playground has no 'Predict before' prompt")
            if explanation_count < prediction_count:
                warnings.append(
                    "playground has fewer collapsed explanations than prediction prompts"
                )
            passes.append(f"playground source is present with {control_count} controls")
    else:
        warnings.append("no playground path supplied; interactive structure was not audited")

    print_report(session_dir, errors, warnings, passes, snapshot)
    return 1 if errors else 0


def print_report(
    session_dir: Path,
    errors: list[str],
    warnings: list[str],
    passes: list[str],
    snapshot: dict[str, int | str],
) -> None:
    print(f"Session audit: {session_dir}")
    for message in passes:
        print(f"  PASS  {message}")
    for message in warnings:
        print(f"  WARN  {message}")
    for message in errors:
        print(f"  ERROR {message}")
    if snapshot:
        print("  Snapshot")
        width = max(len(key) for key in snapshot)
        for key, value in snapshot.items():
            print(f"    {key:<{width}}  {value}")
    print("  Result: " + ("FAIL" if errors else "PASS"))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("session_dir", type=Path, help="session source directory")
    parser.add_argument(
        "--playground",
        type=Path,
        help="optional interactive playground source associated with the session",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parents[1]
    session_dir = args.session_dir
    if not session_dir.is_absolute():
        session_dir = repo_root / session_dir
    playground = args.playground
    if playground is not None and not playground.is_absolute():
        playground = repo_root / playground
    return audit(session_dir.resolve(), playground.resolve() if playground else None)


if __name__ == "__main__":
    sys.exit(main())
