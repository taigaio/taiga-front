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
# File: modules/auth.coffee
###

taiga = @.taiga

class AuthService extends taiga.Service
    @.$inject = ["$rootScope", "$tgStorage", "$tgModel", "$tgHttp", "$tgUrls"]

    constructor: (@rootscope, @storage, @model, @http, @urls) ->
        super()

    getUser: ->
        if @rootscope.user
            return @rootscope.user

        userData = @storage.get("userInfo")
        if userData
            user = @model.make_model("users", userData)
            @rootscope.user = user
            return user

        return null

    setUser: (user) ->
        @rootscope.auth = user
        @rootscope.$broadcast("i18n:change", user.default_language)
        @storage.set("userInfo", user.getAttrs())

    clear: ->
        @rootscope.auth = null
        @storage.remove("userInfo")

    setToken: (token) ->
        @storage.set("token", token)

    getToken: ->
        return @storage.get("token")

    isAuthenticated: ->
        if @.getUser() != null
            return true
        return false

    ###################
    ## Http interface
    ###################

    login: (username, password) ->
        url = @urls.resolve("auth")

        data = {
            username: username
            password: password
            type: "normal"
        }

        return @http.post(url, data).then (data, status) =>
            user = @model.make_model("users", data.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    publicRegister: (data) ->
        url = @urls.resolve("auth-register")

        data = _.clone(data, false)
        data.type = "public"

        return @http.post(url, data).then (response) =>
            user = @model.make_model("users", response.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    # acceptInvitiationWithNewUser: (username, email, password, token) ->
    #     url = @urls.resolve("auth-register")
    #     data = _.extend(data, {
    #         username: username,
    #         password: password,
    #         token: token
    #         email: email
    #         existing: "off"
    #     }
    #     return @http.post(url, data).then (response) =>
    #         user = @model.make_model("users", response.data)
    #         @.setToken(user.auth_token)
    #         @.setUser(user)
    #         return user

    # acceptInvitiationWithExistingUser: (username, password, token) ->
    #     url = @urls.resolve("auth-register")
    #     data = _.extend(data, {
    #         username: username,
    #         password: password,
    #         token: token,
    #         existing: "on"
    #     }
    #     return @http.post(url, data).then (response) =>
    #         user = @model.make_model("users", response.data)
    #         @.setToken(user.auth_token)
    #         @.setUser(user)
    #         return user


class AuthController extends taiga.Controller
    @.$inject = ["$scope", "$tgAuth", "$location"]

    constructor: (@scope, @auth, @location) ->
        @scope.form = {username: "", password: ""}

    submit: ->
        @auth.login(@scope.form.username, @scope.form.password).then (user) =>
            #TODO: fix this
            @location.path("/project/project-example-0/backlog")



RegisterDirective = ($auth, $confirm) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        submit = ->
            if not form.validate()
                return

            promise = $auth.publicRegister($scope.data)
            promise.then (response) ->
                # TODO: finish this.
                console.log response

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.error(response.data._error_message)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-register", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module = angular.module("taigaAuth", ["taigaResources"])
module.service("$tgAuth", AuthService)
module.controller("AuthController", AuthController)
module.directive("tgRegister", ["$tgAuth", "$tgConfirm", RegisterDirective])
