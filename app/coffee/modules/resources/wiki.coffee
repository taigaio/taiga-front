###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
