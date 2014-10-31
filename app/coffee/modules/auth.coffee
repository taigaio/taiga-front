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
debounce = @.taiga.debounce

module = angular.module("taigaAuth", ["taigaResources"])

#############################################################################
## Authentication Service
#############################################################################

class AuthService extends taiga.Service
    @.$inject = ["$rootScope",
                 "$tgStorage",
                 "$tgModel",
                 "$tgResources",
                 "$tgHttp",
                 "$tgUrls"]

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
        @rootscope.user = user

    clear: ->
        @rootscope.auth = null
        @rootscope.user = null
        @storage.remove("userInfo")

    setToken: (token) ->
        @storage.set("token", token)

    getToken: ->
        return @storage.get("token")

    removeToken: ->
        @storage.remove("token")

    isAuthenticated: ->
        if @.getUser() != null
            return true
        return false

    ## Http interface

    login: (data, type) ->
        url = @urls.resolve("auth")

        data = _.clone(data, false)
        data.type = if type then type else "normal"

        @.removeToken()

        return @http.post(url, data).then (data, status) =>
            user = @model.make_model("users", data.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    logout: ->
        @.removeToken()
        @.clear()

    register: (data, type, existing) ->
        url = @urls.resolve("auth-register")

        data = _.clone(data, false)
        data.type = if type then type else "public"
        if type == "private"
            data.existing = if existing then existing else false

        @.removeToken()

        return @http.post(url, data).then (response) =>
            user = @model.make_model("users", response.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            return user

    getInvitation: (token) ->
        return @rs.invitations.get(token)

    acceptInvitiationWithNewUser: (data) ->
        return @.register(data, "private", false)

    acceptInvitiationWithExistingUser: (data) ->
        return @.register(data, "private", true)

    forgotPassword: (data) ->
        url = @urls.resolve("users-password-recovery")
        data = _.clone(data, false)
        @.removeToken()
        return @http.post(url, data)

    changePasswordFromRecovery: (data) ->
        url = @urls.resolve("users-change-password-from-recovery")
        data = _.clone(data, false)
        @.removeToken()
        return @http.post(url, data)

    changeEmail: (data) ->
        url = @urls.resolve("users-change-email")
        data = _.clone(data, false)
        return @http.post(url, data)

    cancelAccount: (data) ->
        url = @urls.resolve("users-cancel-account")
        data = _.clone(data, false)
        return @http.post(url, data)

module.service("$tgAuth", AuthService)


#############################################################################
## Login Directive
#############################################################################

# Directive that manages the visualization of public register
# message/link on login page.

PublicRegisterMessageDirective = ($config, $navUrls) ->
    template = _.template("""
    <p class="login-text">
        <span>Not registered yet?</span>
        <a href="<%- url %>" tg-nav="register" title="Register"> create your free account here</a>
    </p>""")

    templateFn = ->
        publicRegisterEnabled = $config.get("publicRegisterEnabled")
        if not publicRegisterEnabled
            return ""
        return template({url:$navUrls.resolve("register")})

    return {
        restrict: "AE"
        scope: {}
        template: templateFn
    }

module.directive("tgPublicRegisterMessage", ["$tgConfig", "$tgNavUrls", PublicRegisterMessageDirective])


LoginDirective = ($auth, $confirm, $location, $config, $routeParams, $navUrls, $events) ->
    link = ($scope, $el, $attrs) ->
        onSuccess = (response) ->
            if $routeParams['next'] and $routeParams['next'] != $navUrls.resolve("login")
                nextUrl = $routeParams['next']
            else
                nextUrl = $navUrls.resolve("home")

            $events.setupConnection()
            $location.path(nextUrl)

        onError = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas, your username/email
                                            or password are incorrect.") #TODO: i18n
        submit = ->
            form = new checksley.Form($el.find("form.login-form"))
            if not form.validate()
                return

            data = {
                "username": $el.find("form.login-form input[name=username]").val(),
                "password": $el.find("form.login-form input[name=password]").val()
            }

            promise = $auth.login(data)
            return promise.then(onSuccess, onError)

        $el.on "click", "a.button-login", (event) ->
            event.preventDefault()
            submit()

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLogin", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgConfig", "$routeParams",
                             "$tgNavUrls", "$tgEvents", LoginDirective])

#############################################################################
## Register Directive
#############################################################################

RegisterDirective = ($auth, $confirm, $location, $navUrls, $config, $analytics) ->
    link = ($scope, $el, $attrs) ->
        if not $config.get("publicRegisterEnabled")
            $location.path($navUrls.resolve("not-found"))
            $location.replace()

        $scope.data = {}
        form = $el.find("form").checksley({onlyOneErrorElement: true})

        onSuccessSubmit = (response) ->
            $analytics.trackEvent("auth", "register", "user registration", 1)
            $confirm.notify("success", "Our Oompa Loompas are happy, welcome to Taiga.") #TODO: i18n
            $location.path($navUrls.resolve("home"))

        onErrorSubmit = (response) ->
            if response.data._error_message?
                $confirm.notify("light-error", "According to our Oompa Loompas there was an error. #{response.data._error_message}") #TODO: i18n

            form.setErrors(response.data)

        submit = debounce 2000, =>
            if not form.validate()
                return

            promise = $auth.register($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-register", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgRegister", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgNavUrls", "$tgConfig",
                                "$tgAnalytics", RegisterDirective])

#############################################################################
## Forgot Password Directive
#############################################################################

ForgotPasswordDirective = ($auth, $confirm, $location, $navUrls) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $location.path($navUrls.resolve("login"))
            $confirm.success("<strong>Check your inbox!</strong><br />
                             We have sent a mail to<br />
                             <strong>#{response.data.email}</strong><br />
                             with the instructions to set a new password") #TODO: i18n

        onErrorSubmit = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas,
                                            your are not registered yet.") #TODO: i18n

        submit = debounce 2000, =>
            if not form.validate()
                return

            promise = $auth.forgotPassword($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-forgot", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgForgotPassword", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgNavUrls",
                                      ForgotPasswordDirective])

#############################################################################
## Change Password from Recovery Directive
#############################################################################

ChangePasswordFromRecoveryDirective = ($auth, $confirm, $location, $params, $navUrls) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}

        if $params.token?
            $scope.tokenInParams = true
            $scope.data.token = $params.token
        else
            $scope.tokenInParams = false

        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $location.path($navUrls.resolve("login"))
            $confirm.success("Our Oompa Loompas saved your new password.<br />
                              Try to <strong>sign in</strong> with it.") #TODO: i18n

        onErrorSubmit = (response) ->
            $confirm.notify("light-error", "One of our Oompa Loompas say
                            '#{response.data._error_message}'.") #TODO: i18n

        submit = debounce 2000, =>
            if not form.validate()
                return

            promise = $auth.changePasswordFromRecovery($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-change-password", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgChangePasswordFromRecovery", ["$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                                  "$tgNavUrls", ChangePasswordFromRecoveryDirective])

#############################################################################
## Invitation
#############################################################################

InvitationDirective = ($auth, $confirm, $location, $params, $navUrls, $analytics) ->
    link = ($scope, $el, $attrs) ->
        token = $params.token

        promise = $auth.getInvitation(token)
        promise.then (invitation) ->
            $scope.invitation = invitation

        promise.then null, (response) ->
            $location.path($navUrls.resolve("login"))
            $confirm.success("<strong>Ooops, we have a problem</strong><br />
                              Our Oompa Loompas can't find your invitation.") #TODO: i18n

        # Login form
        $scope.dataLogin = {token: token}
        loginForm = $el.find("form.login-form").checksley({onlyOneErrorElement: true})

        onSuccessSubmitLogin = (response) ->
            $analytics.trackEvent("auth", "invitationAccept", "invitation accept with existing user", 1)
            $location.path($navUrls.resolve("project", {project: $scope.invitation.project_slug}))
            $confirm.notify("success", "You've successfully joined this project",
                                       "Welcome to #{_.escape($scope.invitation.project_name)}")

        onErrorSubmitLogin = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas, your are not registered yet or
                                            typed an invalid password.") #TODO: i18n

        submitLogin = debounce 2000, =>
            if not loginForm.validate()
                return

            promise = $auth.acceptInvitiationWithExistingUser($scope.dataLogin)
            promise.then(onSuccessSubmitLogin, onErrorSubmitLogin)

        $el.on "submit", "form.login-form", (event) ->
            event.preventDefault()
            submitLogin()

        $el.on "click", "a.button-login", (event) ->
            event.preventDefault()
            submitLogin()

        # Register form
        $scope.dataRegister = {token: token}
        registerForm = $el.find("form.register-form").checksley()

        onSuccessSubmitRegister = (response) ->
            $analytics.trackEvent("auth", "invitationAccept", "invitation accept with new user", 1)
            $location.path($navUrls.resolve("project", {project: $scope.invitation.project_slug}))
            $confirm.notify("success", "You've successfully joined this project",
                                       "Welcome to #{_.escape($scope.invitation.project_name)}")

        onErrorSubmitRegister = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas, that
                                            username or email is already in use.") #TODO: i18n

        submitRegister = debounce 2000, =>
            if not registerForm.validate()
                return

            promise = $auth.acceptInvitiationWithNewUser($scope.dataRegister)
            promise.then(onSuccessSubmitRegister, onErrorSubmitRegister)

        $el.on "submit", "form.register-form", (event) ->
            event.preventDefault()
            submitRegister

        $el.on "click", "a.button-register", (event) ->
            event.preventDefault()
            submitRegister()

    return {link:link}

module.directive("tgInvitation", ["$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                  "$tgNavUrls", "$tgAnalytics", InvitationDirective])

#############################################################################
## Change Email
#############################################################################

ChangeEmailDirective = ($repo, $model, $auth, $confirm, $location, $params, $navUrls) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        $scope.data.email_token = $params.email_token
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $repo.queryOne("users", $auth.getUser().id).then (data) =>
                $auth.setUser(data)
                $location.path($navUrls.resolve("home"))
                $confirm.success("Our Oompa Loompas updated your email") #TODO: i18n

        onErrorSubmit = (response) ->
            $confirm.notify("error", "One of our Oompa Loompas says
                            '#{response.data._error_message}'.") #TODO: i18n

        submit = ->
            if not form.validate()
                return

            promise = $auth.changeEmail($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-change-email", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgChangeEmail", ["$tgRepo", "$tgModel", "$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                   "$tgNavUrls", ChangeEmailDirective])

#############################################################################
## Cancel account
#############################################################################

CancelAccountDirective = ($repo, $model, $auth, $confirm, $location, $params, $navUrls) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        $scope.data.cancel_token = $params.cancel_token
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $auth.logout()
            $location.path($navUrls.resolve("home"))
            $confirm.success("Our Oompa Loompas removed your account") #TODO: i18n

        onErrorSubmit = (response) ->
            $confirm.notify("error", "One of our Oompa Loompas says
                            '#{response.data._error_message}'.") #TODO: i18n

        submit = ->
            if not form.validate()
                return

            promise = $auth.cancelAccount($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "a.button-cancel-account", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgCancelAccount", ["$tgRepo", "$tgModel", "$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                   "$tgNavUrls", CancelAccountDirective])
