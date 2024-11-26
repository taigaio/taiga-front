###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

        $el.on "click", ".js-cancel", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $el.on "click", ".js-confirm", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbDeleteProject", ["$tgRepo", "$rootScope", "$tgAuth", "$tgLocation", "$tgNavUrls",
                                       "$tgConfirm", "lightboxService", "tgLoader", "tgCurrentUserService",
                                       "$tgAnalytics", DeleteProjectDirective])
