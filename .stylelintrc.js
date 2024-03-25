/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

module.exports = {
  root: true,
  extends: ['stylelint-config-standard'],
  plugins: ['stylelint-order', 'stylelint-scss'],
  rules: {
    'at-rule-no-unknown': [
      true,
      {
        ignoreAtRules: ['define-mixin', 'mixin', 'include', 'extend', 'each', 'for'],
      },
    ],
    // Using quotes
    'font-family-name-quotes': 'always-unless-keyword',
    'function-url-quotes': 'always',
    'selector-attribute-quotes': 'always',
    'string-quotes': 'single',
    // Disallow vendor prefixes
    'at-rule-no-vendor-prefix': true,
    'media-feature-name-no-vendor-prefix': true,
    'property-no-vendor-prefix': true,
    'selector-no-vendor-prefix': true,
    'value-no-vendor-prefix': true,
    // Specificity
    'max-nesting-depth': 4,
    'selector-max-specificity': "1,2,1",
    // Miscellanea
    'color-named': 'never',
    'color-no-hex': true,
    'declaration-no-important': true,
    'declaration-property-unit-whitelist': {
      "font-size": ["rem", "em"], // todo: no em?
      "/^animation/": ["s"]
    },
    'number-leading-zero': 'never',
    'order/properties-alphabetical-order': true,
    'selector-max-type': 1,

    'selector-type-no-unknown': [
      true,
      {
        ignore: ['custom-elements'],
      },
    ],
    // Notation
    'font-weight-notation': 'numeric',
    // URLs
    'function-url-no-scheme-relative': true,
    // Max line length
    'max-line-length': [
      120,
      {
        ignore: ['comments'],
      }
    ],
    // Fix
    "indentation": [
        4
    ],
    "rule-empty-line-before": null,
    "declaration-empty-line-before": null,
    "no-empty-source": null,
    "selector-combinator-space-after": null,
    "selector-max-type": null,
    "no-descending-specificity": null,
    "max-empty-lines": null,
    "block-closing-brace-empty-line-before": null,
    'selector-max-compound-selectors': 5,
    "block-closing-brace-empty-line-before": null,
    "selector-combinator-space-before": null,
    "at-rule-empty-line-before": null,
    "function-calc-no-unspaced-operator": null,
    "declaration-property-unit-whitelist": null,
    "font-weight-notation": null,
    "font-family-no-missing-generic-family-keyword": null
  },
};
