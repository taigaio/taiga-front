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
# File: modules/resources/wiki.coffee
###


taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (wikiId) ->
        return $repo.queryOne("wiki", wikiId)

    service.getBySlug = (projectId, slug) ->
        return $repo.queryOne("wiki", "by_slug?project=#{projectId}&slug=#{slug}")

    service.list = (projectId) ->
        return $repo.queryMany("wiki", {project: projectId})

    service.listLinks = (projectId) ->
        return $repo.queryMany("wiki-links", {project: projectId})

    return (instance) ->
        instance.wiki = service


module = angular.module("taigaResources")
module.factory("$tgWikiResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
