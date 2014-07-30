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
# File: modules/user-settings/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

module = angular.module("taigaUserSettings")


#############################################################################
## User settings Controller
#############################################################################

class UserSettingsController extends mixOf(taiga.Controller, taiga.PageMixin)
      @.$inject = [
          "$scope",
          "$rootScope",
          "$tgRepo",
          "$tgConfirm",
          "$tgResources",
          "$routeParams",
          "$q",
          "$location",
          "$tgAuth"
      ]

      constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @auth) ->
          @scope.sectionName = "User Settings" #i18n
          @scope.project = {}
          @scope.user = @auth.getUser()

          promise = @.loadInitialData()
          promise.then null, ->
              console.log "FAIL" #TODO

      loadProject: ->
          return @rs.projects.get(@scope.projectId).then (project) =>
              @scope.project = project
              @scope.$emit('project:loaded', project)
              return project

      loadInitialData: ->
          promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
              @scope.projectId = data.project
              return data

          return promise.then(=> @.loadProject())

      saveUserProfile: ->

          updatingEmail = @scope.user.isAttributeModified("email")
          promise = @repo.save(@scope.user)
          promise.then =>
              @auth.setUser(@scope.user)
              if updatingEmail
                  @confirm.success("<strong>Check your inbox!</strong><br />
                         We have sent a mail to your account<br />
                         with the instructions to set your new address") #TODO: i18n

              else
                  @confirm.notify('success')

          promise.then null, (response) =>
              @confirm.notify('error', response._error_message)
              @scope.user = @auth.getUser()

      openDeleteLightbox: ->
          @rootscope.$broadcast("deletelightbox:new", @scope.user)


module.controller("UserSettingsController", UserSettingsController)

#############################################################################
## User Profile Directive
#############################################################################

UserProfileDirective = () ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()

        $el.on "click", ".user-profile form .save-profile", (event) ->
            return if not form.validate()
            target = angular.element(event.currentTarget)
            $ctrl = $el.controller()
            $ctrl.saveUserProfile()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgUserProfile", UserProfileDirective)


#############################################################################
## User Avatar Directive
#############################################################################

UserAvatarDirective = ($auth, $model, $rs, $confirm) ->
    link = ($scope, $el, $attrs) ->

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".button.change", ->
            $el.find("#avatar-field").click()

        $el.on "change", "#avatar-field", (event) ->
            target = angular.element(event.currentTarget)

            promise = $rs.userSettings.changeAvatar($scope.avatarAttachment)

            promise.then (response) ->
                user = $model.make_model("users", response.data)
                $auth.setUser(user)
                $scope.user = user
                $confirm.notify('success')
            promise.then null, (response) ->
                console.log response
                $confirm.notify('error', response.data._error_message)

    return {link:link}

module.directive("tgUserAvatar", ["$tgAuth", "$tgModel", "$tgResources", "$tgConfirm", UserAvatarDirective])

#############################################################################
## User Avatar Model Directive
#############################################################################

TaigaAvatarModelDirective = ($parse) ->
    link = ($scope, $el, $attrs) ->
        model = $parse($attrs.tgAvatarModel)
        modelSetter = model.assign

        $el.bind 'change', ->
            $scope.$apply ->
                modelSetter($scope, $el[0].files[0])

    return {link:link}

module.directive('tgAvatarModel', ['$parse', TaigaAvatarModelDirective])
