###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/common/attachments.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
timeout = @.taiga.timeout
debounce = @.taiga.debounce

module = angular.module("taigaProject")

#############################################################################
## Delete Project Lightbox Directive
#############################################################################

DeleteProjectDirective = ($repo, $rootscope, $auth, $location, $navUrls, $confirm, lightboxService, tgLoader, currentUserService, $analytics) ->
    link = ($scope, $el, $attrs) ->
        projectToDelete = null
        $scope.$on "deletelightbox:new", (ctx, project)->
            lightboxService.open($el)
            projectToDelete = project

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            tgLoader.start()
            lightboxService.close($el)

            promise = $repo.remove(projectToDelete)

            promise.then (data) ->
                $analytics.trackEvent("projects", "delete", "Delete project", 1)
                tgLoader.pageLoaded()
                $rootscope.$broadcast("projects:reload")
                $location.path($navUrls.resolve("home"))
                $confirm.notify("success")
                currentUserService.loadProjects()

            # FIXME: error handling?
            promise.then null, ->
                $confirm.notify("error")
                lightboxService.close($el)

        $el.on "click", ".button-red", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbDeleteProject", ["$tgRepo", "$rootScope", "$tgAuth", "$tgLocation", "$tgNavUrls",
                                       "$tgConfirm", "lightboxService", "tgLoader", "tgCurrentUserService",
                                       "$tgAnalytics", DeleteProjectDirective])
