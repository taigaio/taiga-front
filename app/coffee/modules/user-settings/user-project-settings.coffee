###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
mixOf = @.taiga.mixOf
bindOnce = @.taiga.bindOnce

module = angular.module("taigaUserSettings")


#############################################################################
## Custom Homepage Controller
#############################################################################

class UserProjectSettingsController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$rootScope"
        "$scope"
        "$tgSections"
        "$tgResources"
        "$tgRepo"
        "$tgConfirm"
         "tgCurrentUserService"
    ]

    constructor: (@rootScope, @scope, @tgSections, @rs, @repo, @confirm, @currentUserService) ->
        @scope.sections = @tgSections.list()

        promise = @.loadInitialData()
        promise.then null, @.onInitialDataError.bind(@)

    loadInitialData: ->
        return @rs.userProjectSettings.list().then (userProjectSettings) =>
            @scope.userProjectSettings = userProjectSettings

    updateCustomHomePage: (projectSettings) ->
        onSuccess = =>
            @currentUserService.loadProjects()
            @rootScope.$broadcast("dropdown-project-list:updated")
            @confirm.notify("success")

        onError = =>
            @confirm.notify("error")

        @repo.save(projectSettings).then(onSuccess, onError)

    filteredSections: (projectSettings) ->
        return _.filter @scope.sections, (section) ->
            section.id in projectSettings.allowed_sections


module.controller("UserProjectSettingsController", UserProjectSettingsController)
