###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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

CreateProject = ($rootscope, $repo, $confirm, $location, $navurls, $rs, $projectUrl, $loading, lightboxService, $cacheFactory, $translate, currentUserService, $auth) ->
    link = ($scope, $el, attrs) ->
        $scope.data = {}
        $scope.templates = []
        currentLoading = null

        form = $el.find("form").checksley({"onlyOneErrorElement": true})

        onSuccessSubmit = (response) ->
            # remove all $http cache
            # This is necessary when a project is created with the same name
            # than another deleted in the same session
            $cacheFactory.get('$http').removeAll()

            currentLoading.finish()
            $rootscope.$broadcast("projects:reload")

            $confirm.notify("success", $translate.instant("COMMON.SAVE"))

            $location.url($projectUrl.get(response))
            lightboxService.close($el)
            currentUserService.loadProjects()

        onErrorSubmit = (response) ->
            currentLoading.finish()
            form.setErrors(response)
            selectors = []
            for error_field in _.keys(response)
                selectors.push("[name=#{error_field}]")

        submit = (event) =>
            event.preventDefault()

            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.create("projects", $scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        openLightbox = ->
            $scope.data = {
                is_private: false
            }

            if !$scope.templates.length
                $rs.projects.templates().then (result) =>
                    $scope.templates = result
                    $scope.data.creation_template = _.head(_.filter($scope.templates, (x) -> x.slug == "scrum")).id
            else
                $scope.data.creation_template = _.head(_.filter($scope.templates, (x) -> x.slug == "scrum")).id

            $scope.canCreatePrivateProjects = currentUserService.canCreatePrivateProjects()
            $scope.canCreatePublicProjects = currentUserService.canCreatePublicProjects()

            lightboxService.open($el)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $scope.$on "$destroy", ->
            $el.off()

        $auth.refresh().then () ->
            openLightbox()

    directive = {
        link: link,
        templateUrl: "project/wizard-create-project.html"
        scope: {}
    }

    return directive


module.directive("tgLbCreateProject", ["$rootScope", "$tgRepo", "$tgConfirm",
    "$location", "$tgNavUrls", "$tgResources", "$projectUrl", "$tgLoading",
    "lightboxService", "$cacheFactory", "$translate", "tgCurrentUserService", "$tgAuth", CreateProject])


#############################################################################
## Delete Project Lightbox Directive
#############################################################################

DeleteProjectDirective = ($repo, $rootscope, $auth, $location, $navUrls, $confirm, lightboxService, tgLoader, currentUserService) ->
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
                                       "$tgConfirm", "lightboxService", "tgLoader", "tgCurrentUserService", DeleteProjectDirective])
