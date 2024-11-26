/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

// https://github.com/Galadirith/markdown-it-lazy-headers
// Copyright (c) 2015 Edward Fauchon-Jones

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// ------------------------------------------------------------------------

// This repository incorporates code from
// [markdown-it](https://github.com/markdown-it/markdown-it) covered by the
// following terms:

// > Copyright (c) 2014 Vitaly Puzrin, Alex Kocharin.
// >
// > Permission is hereby granted, free of charge, to any person
// > obtaining a copy of this software and associated documentation
// > files (the "Software"), to deal in the Software without
// > restriction, including without limitation the rights to use,
// > copy, modify, merge, publish, distribute, sublicense, and/or sell
// > copies of the Software, and to permit persons to whom the
// > Software is furnished to do so, subject to the following
// > conditions:
// >
// > The above copyright notice and this permission notice shall be
// > included in all copies or substantial portions of the Software.
// >
// > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// > EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// > OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// > NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// > HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// > WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// > FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// > OTHER DEALINGS IN THE SOFTWARE.

// ------------------------------------------------------------------------

// This repository incorporates code from
// [markdown-it-math](https://github.com/runarberg/markdown-it-math) covered by the
// following terms:

// > Copyright (c) 2015 Rúnar Berg Baugsson Sigríðarson
// >
// > Permission is hereby granted, free of charge, to any person obtaining a copy
// > of this software and associated documentation files (the "Software"), to deal
// > in the Software without restriction, including without limitation the rights
// > to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// > copies of the Software, and to permit persons to whom the Software is
// > furnished to do so, subject to the following conditions:
// >
// > The above copyright notice and this permission notice shall be included in
// > all copies or substantial portions of the Software.
// >
// > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// > OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// > THE SOFTWARE.

(function() {
'use strict';

window.markdownitLazyHeaders = function lazy_headers_plugin(md) {
  function heading(state, startLine, endLine, silent) {
    var ch, level, tmp, token,
        pos = state.bMarks[startLine] + state.tShift[startLine],
        max = state.eMarks[startLine];

    ch  = state.src.charCodeAt(pos);

    if (ch !== 0x23/* # */ || pos >= max) { return false; }

    // count heading level
    level = 1;
    ch = state.src.charCodeAt(++pos);
    while (ch === 0x23/* # */ && pos < max && level <= 6) {
      level++;
      ch = state.src.charCodeAt(++pos);
    }

    if (level > 6) { return false; }

    if (silent) { return true; }

    // Let's cut tails like '    ###  ' from the end of string

    max = state.skipCharsBack(max, 0x20, pos); // space
    tmp = state.skipCharsBack(max, 0x23, pos); // #
    if (tmp > pos && state.src.charCodeAt(tmp - 1) === 0x20/* space */) {
      max = tmp;
    }

    state.line = startLine + 1;

    token        = state.push('heading_open', 'h' + String(level), 1);
    token.markup = '########'.slice(0, level);
    token.map    = [ startLine, state.line ];

    token          = state.push('inline', '', 0);
    token.content  = state.src.slice(pos, max).trim();
    token.map      = [ startLine, state.line ];
    token.children = [];

    token        = state.push('heading_close', 'h' + String(level), -1);
    token.markup = '########'.slice(0, level);

    return true;
  }

  md.block.ruler.at('heading', heading, {
    alt: [ 'paragraph', 'reference', 'blockquote' ]
  });
};
}());
