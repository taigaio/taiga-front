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
timeout = @.taiga.timeout
debounce = @.taiga.debounce

module = angular.module("taigaProject")

CreateProject = ($rootscope, $repo, $confirm, $location, $navurls, $rs, $projectUrl, $loading, lightboxService, $cacheFactory, $translate, currentUserService) ->
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
            $el.find(".active").removeClass("active")
            error_step = $el.find(selectors.join(",")).first().parents(".wizard-step")
            error_step.addClass("active")
            $el.find('.progress-bar').removeClass().addClass('progress-bar').addClass(error_step.data("step"))

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
            $scope.data = {}

            if !$scope.templates.length
                $rs.projects.templates().then (result) =>
                    $scope.templates = result
                    $scope.data.creation_template = _.head(_.filter($scope.templates, (x) -> x.slug == "scrum")).id
            else
                $scope.data.creation_template = _.head(_.filter($scope.templates, (x) -> x.slug == "scrum")).id

            $el.find(".active").removeClass("active")
            $el.find(".create-step1").addClass("active")

            lightboxService.open($el)
            timeout 600, ->
                $el.find(".progress-bar").addClass('step1')

        $el.on "click", ".button-next", (event) ->
            event.preventDefault()

            current = $el.find(".active")

            valid = true
            for field in form.fields
                if current.find("[name=#{field.element.attr('name')}]").length
                    valid = field.validate() != false and valid

            if not valid
                return

            next = current.next()
            current.toggleClass('active')
            next.toggleClass('active')
            step = next.data('step')
            $el.find('.progress-bar').removeClass().addClass('progress-bar').addClass(step)

        $el.on "click", ".button-prev", (event) ->
            event.preventDefault()
            current = $el.find(".active")
            prev = current.prev()
            current.toggleClass('active')
            prev.toggleClass('active')
            step = prev.data('step')
            $el.find('.progress-bar').removeClass().addClass('progress-bar').addClass(step)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $scope.$on "$destroy", ->
            $el.off()

        openLightbox()

    directive = {
        link: link,
        templateUrl: "project/wizard-create-project.html"
        scope: {}
    }

    return directive


module.directive("tgLbCreateProject", ["$rootScope", "$tgRepo", "$tgConfirm",
    "$location", "$tgNavUrls", "$tgResources", "$projectUrl", "$tgLoading",
    "lightboxService", "$cacheFactory", "$translate", "tgCurrentUserService", CreateProject])


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
