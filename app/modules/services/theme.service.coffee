###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga


class ThemeService extends taiga.Service
    use: (themeName) ->
        stylesheetEl = $("link[rel='stylesheet']:first")

        if stylesheetEl.length == 0
            stylesheetEl = $("<link rel='stylesheet' href='' type='text/css'>")
            $("head").append(stylesheetEl)

        stylesheetEl.attr("href", "#{window._version}/styles/theme-#{themeName}.css")


angular.module("taigaCommon").service("tgThemeService", ThemeService)
