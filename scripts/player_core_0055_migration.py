#!/usr/bin/env python3
"""Apply or check the exact OmenPath move set in the Player Core 0055 map."""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
from pathlib import Path


ARCHIVE = Path(__file__).resolve().parents[1]
WORKSPACE = ARCHIVE.parent
MAP_PATH = ARCHIVE / "docs/migrations/player-core-0055-v1.0.0.json"
PUBLICATION = "paizo-pathfinder-player-core"


def load_map() -> dict:
    data = json.loads(MAP_PATH.read_text(encoding="utf-8"))
    moves = data.get("moves", [])
    if data.get("format") != "openomen.omenpath-migration-map" or data.get("ticket") != "0055":
        raise ValueError("unexpected migration map format or ticket")
    if len(moves) != 107:
        raise ValueError(f"expected 107 move rows, found {len(moves)}")
    old_paths = [row["oldArchiveRelativePath"] for row in moves]
    new_paths = [row["newArchiveRelativePath"] for row in moves]
    if len(set(old_paths)) != 107 or len(set(new_paths)) != 107:
        raise ValueError("migration map contains duplicate old or new paths")
    class_count = sum(row["id"].startswith("class:") for row in moves)
    archetype_count = sum(row["id"].startswith("archetype:") for row in moves)
    if (class_count, archetype_count) != (50, 57):
        raise ValueError(f"expected 50 class options and 57 archetype feats, found {class_count} and {archetype_count}")
    if data.get("summary", {}).get("totalMoves") != len(moves):
        raise ValueError("map summary does not match move rows")
    format_manifest = json.loads((ARCHIVE / "schemas/archive-format.json").read_text(encoding="utf-8"))
    class_family = next(family for family in format_manifest["families"] if family["id"] == "class")
    standard_children = {child["directory"] for child in class_family.get("children", [])}
    if standard_children != {"features"}:
        raise ValueError(f"class child collections must only declare standard features, found {sorted(standard_children)}")
    expected_groups = {
        (row["id"].split(":")[1], row["collection"]["new"])
        for row in moves
        if row["id"].startswith("class:") and row["collection"]["new"] != "features"
    }
    declared_groups = {
        (group["ownerPath"][0], group["directory"])
        for group in format_manifest.get("customGroups", [])
        if group["familyID"] == "class"
    }
    if declared_groups != expected_groups:
        raise ValueError(f"class custom groups do not match the migration map; missing={sorted(expected_groups - declared_groups)}, extra={sorted(declared_groups - expected_groups)}")
    for row in moves:
        if row["publication"] != PUBLICATION:
            raise ValueError(f"unexpected publication in row {row['id']}")
        if not row["oldOmenPath"].endswith(f"?source={PUBLICATION}") or not row["newOmenPath"].endswith(f"?source={PUBLICATION}"):
            raise ValueError(f"publication qualifier mismatch in row {row['id']}")
    return data


def yaml_string(value: str) -> str:
    # A JSON string is also a valid YAML scalar and handles punctuation safely.
    return json.dumps(value, ensure_ascii=False)


def foundry_description(owner: str) -> tuple[str, str]:
    source_path = WORKSPACE / "pf2e/packs/classes" / f"{owner}.json"
    record = json.loads(source_path.read_text(encoding="utf-8"))
    system = record["system"]
    description_html = system["description"]["value"]
    # The class description's first paragraph is the source-backed overview. Do not
    # carry Foundry UUID links or class-progression markup into archive prose.
    first_paragraph = re.search(r"<p\b[^>]*>(.*?)</p>", description_html, re.IGNORECASE | re.DOTALL)
    if not first_paragraph:
        raise ValueError(f"Foundry class {owner} has no description paragraph")
    text = first_paragraph.group(1).split("@UUID[", 1)[0]
    text = html.unescape(re.sub(r"<[^>]+>", "", text)).strip()
    if not text:
        raise ValueError(f"Foundry class {owner} has an empty overview")
    book = system["publication"]["title"]
    return text, book


def root_files(data: dict) -> dict[str, str]:
    roots: dict[str, str] = {}
    for bundle in data["bundleRootPrerequisites"]:
        owner = bundle["owner"]
        if bundle["requiredEntryFeatRecordFamily"] != "feat" or not bundle["entryFeatAlreadyInMoveSet"]:
            raise ValueError(f"invalid entry feat contract for {owner}")
        description, book = foundry_description(owner)
        relative_path = bundle["expectedArchiveRelativePath"]
        expected_omen_path = bundle["expectedOmenPath"]
        entry_feat = bundle["requiredEntryFeatOmenPath"]
        if relative_path != f"src/{PUBLICATION}/archetype/{owner}/{owner}.yml":
            raise ValueError(f"unexpected archetype root path for {owner}")
        text = (
            f"name: {yaml_string(owner)}\n"
            "source:\n"
            f"  publisher: {yaml_string('paizo')}\n"
            f"  book: {yaml_string(book)}\n"
            f"description: {yaml_string(description)}\n"
            f"entryFeat: {yaml_string(entry_feat)}\n"
        )
        roots[relative_path] = text
        if not expected_omen_path.endswith(f"/archetype/{owner}?source={PUBLICATION}"):
            raise ValueError(f"unexpected archetype root identity for {owner}")
    if len(roots) != 8:
        raise ValueError(f"expected 8 archetype roots, found {len(roots)}")
    return roots


def absolute_archive_path(relative: str) -> Path:
    path = (ARCHIVE / relative).resolve()
    if ARCHIVE.resolve() not in path.parents:
        raise ValueError(f"path escapes archive: {relative}")
    return path


def check(data: dict) -> None:
    missing: list[str] = []
    stale: list[str] = []
    for row in data["moves"]:
        old = absolute_archive_path(row["oldArchiveRelativePath"])
        new = absolute_archive_path(row["newArchiveRelativePath"])
        if old.exists():
            stale.append(row["oldArchiveRelativePath"])
        if not new.is_file():
            missing.append(row["newArchiveRelativePath"])
    if stale or missing:
        if stale:
            print(f"{len(stale)} old paths still exist; first: {stale[0]}", file=sys.stderr)
        if missing:
            print(f"{len(missing)} new paths are missing; first: {missing[0]}", file=sys.stderr)
        raise ValueError("migration state does not match ticket 0055")
    for relative, expected in root_files(data).items():
        actual = absolute_archive_path(relative)
        if not actual.is_file():
            raise ValueError(f"missing archetype root: {relative}")
        content = actual.read_text(encoding="utf-8")
        if content != expected:
            raise ValueError(f"archetype root differs from its Foundry-backed source: {relative}")
    print("ticket 0055 migration check passed: 107 old paths absent, 107 new paths present, 8 roots verified")


def apply(data: dict) -> None:
    states = []
    for row in data["moves"]:
        old = absolute_archive_path(row["oldArchiveRelativePath"])
        new = absolute_archive_path(row["newArchiveRelativePath"])
        if old.exists() and new.exists():
            raise ValueError(f"both old and new paths exist: {row['id']}")
        if not old.exists() and not new.exists():
            raise ValueError(f"both old and new paths are missing: {row['id']}")
        states.append((old, new))
    roots = root_files(data)
    for relative, expected in roots.items():
        path = absolute_archive_path(relative)
        if path.exists() and path.read_text(encoding="utf-8") != expected:
            raise ValueError(f"refusing to overwrite a non-generated archetype root: {relative}")

    for old, new in states:
        if old.exists():
            new.parent.mkdir(parents=True, exist_ok=True)
            old.rename(new)
    for relative, content in roots.items():
        path = absolute_archive_path(relative)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
    check(data)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--apply", action="store_true", help="move files and create the eight bundle roots")
    action.add_argument("--check", action="store_true", help="verify the exact mapped migration state")
    args = parser.parse_args()
    try:
        data = load_map()
        apply(data) if args.apply else check(data)
    except (OSError, KeyError, ValueError, json.JSONDecodeError) as error:
        print(f"ticket 0055 migration error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
