###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: wiki/history/wiki-history-entry.directive.coffee
###

module = angular.module('taigaWikiHistory')

WikiHistoryEntryDirective = () ->
    link = (scope, el, attr) ->
        scope.singleHistoryEntry = scope.historyEntry.toJS()

    return {
        link: link,
        templateUrl:"wiki/history/wiki-history-entry.html",
        scope: {
            historyEntry: "<"
        }
    }

module.directive("tgWikiHistoryEntry", WikiHistoryEntryDirective)
