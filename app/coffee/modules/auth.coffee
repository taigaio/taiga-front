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

module = angular.module("taigaAuth", ["taigaResources"])

#############################################################################
## Authentication Service
#############################################################################

class AuthService extends taiga.Service
    @.$inject = ["$rootScope", "$tgStorage", "$tgModel", "$tgResources", "$tgHttp", "$tgUrls"]

    constructor: (@rootscope, @storage, @model, @rs, @http, @urls) ->
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

    login: (data, type) ->
        url = @urls.resolve("auth")

        data = _.clone(data, false)
        data.type = if type then type else "normal"

        return @http.post(url, data).then (data, status) =>
            user = @model.make_model("users", data.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    register: (data, type) ->
        url = @urls.resolve("auth-register")

        data = _.clone(data, false)
        data.type = if type then type else "public"
        data.existing = false

        return @http.post(url, data).then (response) =>
            user = @model.make_model("users", response.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    forgotPassword: (data) ->
        url = @urls.resolve("users-password-recovery")

        data = _.clone(data, false)

        return @http.post(url, data)


    changePasswordFromRecovery: (data) ->
        url = @urls.resolve("users-change-password-from-recovery")

        data = _.clone(data, false)

        return @http.post(url, data)

    getInvitation: (token) ->
        return @rs.invitations.get(token)

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

module.service("$tgAuth", AuthService)


#############################################################################
## Auth related directives (login, reguister, invitation)
#############################################################################

    ###################
    ## Login Directive
    ###################

LoginDirective = ($auth, $confirm, $location) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        submit = ->
            if not form.validate()
                return

            promise = $auth.login($scope.data)
            promise.then (response) ->
                # TODO: finish this. Go tu user home page
                $location.path("/project/project-example-0/backlog")

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "According to our Oompa Loompas,
                                                    your username/email or password
                                                    are incorrect.") #TODO: i18n

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-login", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


    ###################
    ## Register Directive
    ###################

RegisterDirective = ($auth, $confirm) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        submit = ->
            if not form.validate()
                return

            promise = $auth.register($scope.data)
            promise.then (response) ->
                $confirm.notify("success", "Our Oompa Loompas are happy, wellcome to Taiga.") #TODO: i18n
                # TODO: finish this. Go tu user home page
                $location.path("/project/project-example-0/backlog")

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "According to our Oompa Loompas,
                                                    your are not registered yet or
                                                    type an invalid password.") #TODO: i18n

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-register", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


    ###################
    ## Forgot Password Directive
    ###################

ForgotPasswordDirective = ($auth, $confirm, $location) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        submit = ->
            if not form.validate()
                return

            promise = $auth.forgotPassword($scope.data)
            promise.then (response) ->
                $location.path("/login") # TODO: Use the future 'urls' service
                $confirm.success("<strong>Check your inbox!</strong><br />
                                 We have sent a mail to<br />
                                 <strong>#{response.data.email}</strong><br />
                                 with the instructions to set a new password") #TODO: i18n

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "According to our Oompa Loompas,
                                                    your are not registered yet.") #TODO: i18n

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-forgot", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


    ###################
    ## Change Password from Recovery Directive
    ###################

ChangePasswordFromRecoveryDirective = ($auth, $confirm, $location, $params) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}

        if $params.token?
            $scope.tokenInParams = true
            $scope.data.token = $params.token
        else
            $scope.tokenInParams = false

        form = $el.find("form").checksley()

        submit = ->
            if not form.validate()
                return

            promise = $auth.changePasswordFromRecovery($scope.data)
            promise.then (response) ->
                $location.path("/login") # TODO: Use the future 'urls' service
                $confirm.success("Our Oompa Loompas save your new password.<br />
                                  Try to <strong>sign in</strong> with it.") #TODO: i18n

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "One of our Oompa Loompas say
                                    '#{response.data._error_message}'.") #TODO: i18n

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-change-password", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


    ###################
    ## Invitation
    ###################

InvitationDirective = ($auth, $confirm, $location, $params) ->
    link = ($scope, $el, $attrs) ->
        token = $params.token

        promise = $auth.getInvitation(token)
        promise.then (invitation)->
            $scope.invitation = invitation

        promise.then null, (response) ->
                $location.path("/login") # TODO: Use the future 'urls' service
                $confirm.success("<strong>Ooops, we have a problems</strong><br />
                                  Our Oompa Loompas can't find your invitations.") #TODO: i18n

        #$##############
        # Login form
        ################
        $scope.dataLogin = {token: token}
        loginForm = $el.find("form.login-form").checksley()

        submitLogin = ->
            if not loginForm.validate()
                return

            promise = $auth.login($scope.dataLogin)
            promise.then (response) ->
                # TODO: finish this. Go tu project home page
                $location.path("/project/#{$scope.invitation.project_slug}/backlog")
                $confirm.notify("success", "You've successfully joined to this project",
                                           "Wellcome to #{$scope.invitation.project_name}")

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "According to our Oompa Loompas,
                                                    your are not registered yet or
                                                    type an invalid password.") #TODO: i18n

        $el.on "submit", "form.login-form", (event) ->
            event.preventDefault()
            submitLogin()

        $el.on "click", "a.button-login", (event) ->
            event.preventDefault()
            submitLogin()

        #$##############
        # Register form
        #$##############
        $scope.dataRegister = {token: token}
        registerForm = $el.find("form.register-form").checksley()

        submitRegister = ->
            if not registerForm.validate()
                return

            promise = $auth.register($scope.dataRegister, "private")
            promise.then (response) ->
                # TODO: finish this. Go tu project home page
                $location.path("/project/#{$scope.invitation.project_slug}/backlog")
                $confirm.notify("success", "You've successfully joined to this project",
                                           "Wellcome to #{$scope.invitation.project_name}")

            promise.then null, (response) ->
                if response.data._error_message
                    $confirm.notify("light-error", "According to our Oompa Loompas,
                                                    your username/email or password
                                                    are incorrect.") #TODO: i18n

        $el.on "submit", "form.register-form", (event) ->
            event.preventDefault()
            submitRegister

        $el.on "click", "a.button-register", (event) ->
            event.preventDefault()
            submitRegister()

    return {link:link}


module.directive("tgRegister", ["$tgAuth", "$tgConfirm", RegisterDirective])
module.directive("tgLogin", ["$tgAuth", "$tgConfirm", "$location", LoginDirective])
module.directive("tgForgotPassword", ["$tgAuth", "$tgConfirm", "$location", ForgotPasswordDirective])
module.directive("tgChangePasswordFromRecovery", ["$tgAuth", "$tgConfirm", "$location", "$routeParams",
                                                  ChangePasswordFromRecoveryDirective])
module.directive("tgInvitation", ["$tgAuth", "$tgConfirm", "$location", "$routeParams",
                                  InvitationDirective])
