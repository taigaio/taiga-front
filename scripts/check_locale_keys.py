#!/usr/bin/env python3
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.

"""Compare translated leaf keys with the English source catalog."""

import argparse
import json
import re
from pathlib import Path


DEFAULT_LOCALES_DIR = Path(__file__).resolve().parents[1] / "app/locales/taiga"


def reject_duplicate_keys(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_catalog(path):
    with path.open(encoding="utf-8") as source:
        catalog = json.load(source, object_pairs_hook=reject_duplicate_keys)
    if not isinstance(catalog, dict):
        raise ValueError("catalog root must be an object")
    return catalog


def symbols(catalog, prefix=""):
    result = set()
    for key, value in catalog.items():
        path = f"{prefix}.{key}" if prefix else key
        if isinstance(value, dict):
            result.update(symbols(value, path))
        elif isinstance(value, str):
            result.add(path)
        else:
            raise ValueError(f"translation is not a string: {path}")
    return result


def differences(expected, actual):
    return sorted(expected - actual), sorted(actual - expected)


def check_locales(locales_dir, baseline=None, locale_codes=None):
    english_path = locales_dir / "locale-en.json"
    english = symbols(load_catalog(english_path))
    if locale_codes is None:
        translations = sorted(
            path for path in locales_dir.glob("locale-*.json")
            if path != english_path
        )
    else:
        if "en" not in locale_codes:
            raise ValueError("supported locales must include en")
        if len(locale_codes) != len(set(locale_codes)) or any(
            not re.fullmatch(r"[a-z]+(?:-[a-z]+)*", code)
            for code in locale_codes
        ):
            raise ValueError("supported locale codes must be unique and valid")
        translations = [locales_dir / f"locale-{code}.json"
                        for code in locale_codes if code != "en"]
    if not translations:
        raise ValueError("no translated catalogs found")

    failures = {}
    for path in translations:
        try:
            found = symbols(load_catalog(path))
            missing, extra = differences(english, found)
            resolved_missing = []
            resolved_extra = []
            if baseline is not None:
                permitted = baseline.get(path.name, {})
                old_missing = set(permitted.get("missing", []))
                old_extra = set(permitted.get("extra", []))
                resolved_missing = sorted(old_missing - set(missing))
                resolved_extra = sorted(old_extra - set(extra))
                missing = sorted(set(missing) - old_missing)
                extra = sorted(set(extra) - old_extra)
            if missing or extra or resolved_missing or resolved_extra:
                failures[path.name] = (missing, extra, [],
                                       resolved_missing, resolved_extra)
        except FileNotFoundError:
            failures[path.name] = ([], [], ["catalog missing"], [], [])
        except (OSError, UnicodeError, ValueError) as error:
            failures[path.name] = ([], [], [str(error)], [], [])
    if baseline is not None:
        for name in sorted(set(baseline) - {path.name for path in translations}):
            failures[name] = ([], [], ["catalog missing"], [], [])
    return len(translations), failures


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locales-dir", type=Path, default=DEFAULT_LOCALES_DIR)
    parser.add_argument("--baseline", type=Path,
                        help="allow only previously reviewed missing/extra keys")
    parser.add_argument("--supported-codes-file", type=Path,
                        help="JSON list of selectable locale codes")
    args = parser.parse_args()
    try:
        baseline = load_catalog(args.baseline) if args.baseline else None
        codes = None
        if args.supported_codes_file:
            with args.supported_codes_file.open(encoding="utf-8") as source:
                codes = json.load(source)
            if not isinstance(codes, list):
                raise ValueError("supported locale codes must be a JSON list")
        count, failures = check_locales(args.locales_dir, baseline, codes)
    except (OSError, UnicodeError, ValueError) as error:
        parser.exit(1, f"locale check failed: {error}\n")

    for name, (missing, extra, different_types,
               resolved_missing, resolved_extra) in failures.items():
        print(f"{name}: {len(missing)} missing, {len(extra)} extra, "
              f"{len(different_types)} invalid or changed type, "
              f"{len(resolved_missing) + len(resolved_extra)} baseline entries resolved")
        for label, paths in (("missing", missing), ("extra", extra),
                             ("invalid/type", different_types),
                             ("remove resolved missing from baseline", resolved_missing),
                             ("remove resolved extra from baseline", resolved_extra)):
            for path in paths[:5]:
                print(f"  {label}: {path}")
            if len(paths) > 5:
                print(f"  {label}: ... and {len(paths) - 5} more")
    if failures:
        print(f"FAIL: {len(failures)}/{count} catalogs differ from English")
        return 1
    if baseline is None:
        print(f"PASS: {count} catalogs have the same keys as English")
    else:
        print(f"PASS: {count} catalogs match the reviewed key baseline")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
