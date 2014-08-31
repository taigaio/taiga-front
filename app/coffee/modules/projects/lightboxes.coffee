###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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

module = angular.module("taigaProject")

CreateProject = ($rootscope, $repo, $confirm, $location, $navurls, $rs, $projectUrl, lightboxService) ->
    link = ($scope, $el, attrs) ->
        $scope.data = {}
        $scope.templates = []
        form = $el.find("form").checksley({"onlyOneErrorElement": true})

        onSuccessSubmit = (response) ->
            lightboxService.close($el)
            $confirm.notify("success", "Success") #TODO: i18n
            $location.url($projectUrl.get(response))
            $rootscope.$broadcast("projects:reload")

        onErrorSubmit = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas, project name is
                                            already in use.") #TODO: i18n

        submit = ->
            if not form.validate()
                return

            promise = $repo.create("projects", $scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $scope.$on "projects:create", ->
            $scope.data = {}

            if !$scope.templates.length
                $rs.projects.templates()
                    .then (result) =>
                        $scope.templates = _.map(result, (item) -> {"id": item.id, "name": item.name})

            lightboxService.open($el)

        $el.on "click", "a.button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbCreateProject", ["$rootScope", "$tgRepo", "$tgConfirm", "$location", "$tgNavUrls",
                                       "$tgResources", "$projectUrl", "lightboxService", CreateProject])


#############################################################################
## Delete Project Lightbox Directive
#############################################################################

DeleteProjectDirective = ($repo, $rootscope, $auth, $location, $navUrls, lightboxService) ->
    link = ($scope, $el, $attrs) ->
        projectToDelete = null
        $scope.$on "deletelightbox:new", (ctx, project)->
            lightboxService.open($el)
            projectToDelete = project

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            promise = $repo.remove(projectToDelete)

            promise.then (data) ->
                lightboxService.close($el)
                $location.path($navUrls.resolve("home"))

            # FIXME: error handling?
            promise.then null, ->
                console.log "FAIL"

        $el.on "click", ".button-red", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbDeleteProject", ["$tgRepo", "$rootScope", "$tgAuth", "$tgLocation", "$tgNavUrls",
                                       "lightboxService", DeleteProjectDirective])
