###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
