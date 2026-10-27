# Locale key parity

Run `python3 scripts/check_locale_keys.py` to compare every shipped
`app/locales/taiga/locale-*.json` translation key with English. The checker
reports missing and extra leaf keys, invalid values, and duplicate JSON
keys. It ignores translated text content. A nonzero exit means at least one
catalog differs.

The backend currently offers 27 selectable languages. Its language list is
mirrored in `scripts/selectable-locale-codes.json`; Hungarian and Indonesian
catalogs are shipped by the frontend but are not selectable. CI runs
`npm run check:locale-keys`, which checks the 27 selectable languages against
`scripts/locale-key-baseline.json`. That baseline records their 349 missing
and 104 extra leaf keys. CI fails for new differences and removed catalogs.
When an old difference is corrected, remove its baseline entry in the same
change. Review the selectable-code list when backend language support
changes.

The baseline is temporary review debt, not a list of desired exceptions.
After translation updates, remove resolved entries. Review any proposed
baseline addition as a new untranslated or obsolete key rather than
regenerating the file automatically. Run the strict command before claiming
complete parity. Send non-English catalog fixes through the project's
translation process.
