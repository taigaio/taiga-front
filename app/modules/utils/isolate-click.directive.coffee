###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

IsolateClickDirective = () ->
    link = (scope, el, attrs) ->
        el.on 'click', (e) =>
            e.stopPropagation()

    return {link: link}

angular.module("taigaUtils").directive("tgIsolateClick", IsolateClickDirective)
