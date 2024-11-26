###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
