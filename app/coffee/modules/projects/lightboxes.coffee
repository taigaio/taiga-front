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
            form.setErrors(response)
            selectors = []
            for error_field in _.keys(response)
                selectors.push("[name=#{error_field}]")
            $el.find(".active").removeClass("active")
            error_step = $el.find(selectors.join(",")).first().parents(".wizard-step")
            error_step.addClass("active")
            $el.find('.progress-bar').removeClass().addClass('progress-bar').addClass(error_step.data("step"))

        submit = ->
            if not form.validate()
                return

            promise = $repo.create("projects", $scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $scope.$on "projects:create", ->
            $scope.$apply ->
                $scope.data = {
                    total_story_points: 100
                    total_milestones: 5
                }

            if !$scope.templates.length
                $rs.projects.templates().then (result) =>
                    $scope.templates = result
                    $scope.data.creation_template = _.head(_.filter($scope.templates, (x) -> x.slug == "scrum")).id
            else
                $scope.$apply ->
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


        $el.on "click", ".button-submit", debounce 2000, (event) ->
            event.preventDefault()
            submit()

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            lightboxService.close($el)

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
