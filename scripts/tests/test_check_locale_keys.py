#!/usr/bin/env python3
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "check_locale_keys.py"
SPEC = importlib.util.spec_from_file_location("check_locale_keys", SCRIPT)
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class CheckLocaleKeysTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.locales_dir = Path(self.temporary.name)
        self.write("en", {"MENU": {"TITLE": "Menu", "OPEN": "Open"}})

    def write(self, locale, catalog):
        path = self.locales_dir / f"locale-{locale}.json"
        path.write_text(json.dumps(catalog), encoding="utf-8")

    def test_matching_nested_keys_allow_different_values(self):
        self.write("fr", {"MENU": {"TITLE": "Menu", "OPEN": "Ouvrir"}})
        self.assertEqual(CHECKER.check_locales(self.locales_dir), (1, {}))

    def test_missing_extra_and_changed_structure_are_reported(self):
        self.write("fr", {"MENU": {"TITLE": "Menu", "CLOSE": "Fermer"}})
        self.write("de", {"MENU": "Menü"})
        count, failures = CHECKER.check_locales(self.locales_dir)
        self.assertEqual(count, 2)
        self.assertEqual(failures["locale-fr.json"],
                         (["MENU.OPEN"], ["MENU.CLOSE"], [], [], []))
        self.assertEqual(failures["locale-de.json"],
                         (["MENU.OPEN", "MENU.TITLE"], ["MENU"], [], [], []))

    def test_duplicate_json_keys_are_rejected(self):
        (self.locales_dir / "locale-fr.json").write_text(
            '{"MENU": {"TITLE": "A", "TITLE": "B"}}', encoding="utf-8"
        )
        _, failures = CHECKER.check_locales(self.locales_dir)
        self.assertIn("duplicate JSON key", failures["locale-fr.json"][2][0])

    def test_baseline_requires_known_gaps_to_match_exactly(self):
        self.write("fr", {"MENU": {"TITLE": "Menu"}})
        baseline = {"locale-fr.json": {"missing": ["MENU.OPEN"], "extra": []}}
        self.assertEqual(CHECKER.check_locales(self.locales_dir, baseline),
                         (1, {}))

        self.write("fr", {"MENU": {"OPEN": "Ouvrir"}})
        _, failures = CHECKER.check_locales(self.locales_dir, baseline)
        self.assertEqual(failures["locale-fr.json"],
                         (["MENU.TITLE"], [], [], ["MENU.OPEN"], []))

        self.write("fr", {"MENU": {"TITLE": "Menu", "OPEN": "Ouvrir"}})
        _, failures = CHECKER.check_locales(self.locales_dir, baseline)
        self.assertEqual(failures["locale-fr.json"],
                         ([], [], [], ["MENU.OPEN"], []))

    def test_no_translated_catalogs_is_an_error(self):
        with self.assertRaisesRegex(ValueError, "no translated catalogs"):
            CHECKER.check_locales(self.locales_dir)

    def test_baselined_catalog_cannot_disappear(self):
        self.write("de", {"MENU": {"TITLE": "Menü", "OPEN": "Öffnen"}})
        self.write("fr", {"MENU": {"TITLE": "Menu", "OPEN": "Ouvrir"}})
        (self.locales_dir / "locale-fr.json").unlink()
        baseline = {"locale-fr.json": {"missing": [], "extra": []}}
        _, failures = CHECKER.check_locales(self.locales_dir, baseline)
        self.assertEqual(failures["locale-fr.json"],
                         ([], [], ["catalog missing"], [], []))

    def test_supported_scope_ignores_unavailable_catalogs(self):
        self.write("fr", {"MENU": {"TITLE": "Menu", "OPEN": "Ouvrir"}})
        self.write("id", {"MENU": {"TITLE": "Menu"}})
        self.assertEqual(
            CHECKER.check_locales(self.locales_dir, locale_codes=["en", "fr"]),
            (1, {}),
        )
        _, failures = CHECKER.check_locales(
            self.locales_dir, locale_codes=["en", "fr", "de"]
        )
        self.assertIn("catalog missing", failures["locale-de.json"][2])

    def test_non_string_translation_is_rejected(self):
        self.write("fr", {"MENU": {"TITLE": None, "OPEN": "Ouvrir"}})
        _, failures = CHECKER.check_locales(self.locales_dir)
        self.assertIn("translation is not a string", failures["locale-fr.json"][2][0])


if __name__ == "__main__":
    unittest.main()
