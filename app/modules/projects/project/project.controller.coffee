###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ProjectController
    @.$inject = [
        "$routeParams",
        "tgAppMetaService",
        "$tgAuth",
        "$translate",
        "tgProjectService",
        "$tgConfig",
        "$tgNavUrls",
        "$location"
    ]

    constructor: (@routeParams, @appMetaService, @auth, @translate, @projectService, @config, @navUrls, @location) ->
        @.user = @auth.userData

        taiga.defineImmutableProperty @, "project", () => return @projectService.project
        taiga.defineImmutableProperty @, "members", () => return @projectService.activeMembers
        taiga.defineImmutableProperty @, "isAuthenticated", () => return !!@.user

        nextUrl = @location.url()
        @.registerUrl = "#{@navUrls.resolve("register")}?next=#{nextUrl}"
        @.loginUrl = "#{@navUrls.resolve("login")}?next=#{nextUrl}"

        @.publicRegisterEnabled = @config.get("publicRegisterEnabled")

        @appMetaService.setfn @._setMeta.bind(this)

    _setMeta: ()->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

angular.module("taigaProjects").controller("Project", ProjectController)
