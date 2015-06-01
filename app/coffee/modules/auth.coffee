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
                 "$tgUrls",
                 "$tgConfig",
                 "$translate",
                 "tgCurrentUserService",
                 "tgThemeService"]

    constructor: (@rootscope, @storage, @model, @rs, @http, @urls, @config, @translate, @currentUserService,
                  @themeService) ->
        super()
        userModel = @.getUser()
        @.setUserdata(userModel)

    setUserdata: (userModel) ->
        if userModel
            @.userData = Immutable.fromJS(userModel.getAttrs())
            @currentUserService.setUser(@.userData)
        else
            @.userData = null

    _setTheme: ->
        theme = @rootscope.user?.theme || @config.get("defaultTheme") || "taiga"
        @themeService.use(theme)

    _setLocales: ->
        lang = @rootscope.user?.lang || @config.get("defaultLanguage") || "en"
        @translate.preferredLanguage(lang)  # Needed for calls to the api in the correct language
        @translate.use(lang)                # Needed for change the interface in runtime

    getUser: ->
        if @rootscope.user
            return @rootscope.user

        userData = @storage.get("userInfo")
        if userData
            user = @model.make_model("users", userData)
            @rootscope.user = user
            @._setLocales()
            @._setTheme()
            return user

        return null

    setUser: (user) ->
        @rootscope.auth = user
        @storage.set("userInfo", user.getAttrs())
        @rootscope.user = user

        @.setUserdata(user)

        @._setLocales()
        @._setTheme()

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
        @currentUserService.removeUser()

        @._setTheme()
        @._setLocales()


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

PublicRegisterMessageDirective = ($config, $navUrls, templates) ->
    template = templates.get("auth/login-text.html", true)

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

module.directive("tgPublicRegisterMessage", ["$tgConfig", "$tgNavUrls", "$tgTemplate",
                                             PublicRegisterMessageDirective])


LoginDirective = ($auth, $confirm, $location, $config, $routeParams, $navUrls, $events, $translate) ->
    link = ($scope, $el, $attrs) ->
        onSuccess = (response) ->
            if $routeParams['next'] and $routeParams['next'] != $navUrls.resolve("login")
                nextUrl = $routeParams['next']
            else
                nextUrl = $navUrls.resolve("home")

            $events.setupConnection()
            $location.path(nextUrl)

        onError = (response) ->
            $confirm.notify("light-error", $translate.instant("LOGIN_FORM.ERROR_AUTH_INCORRECT"))

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = new checksley.Form($el.find("form.login-form"))
            if not form.validate()
                return

            data = {
                "username": $el.find("form.login-form input[name=username]").val(),
                "password": $el.find("form.login-form input[name=password]").val()
            }

            loginFormType = $config.get("loginFormType", "normal")

            promise = $auth.login(data, loginFormType)
            return promise.then(onSuccess, onError)

        $el.on "submit", "form", submit

        window.prerenderReady = true

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgLogin", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgConfig", "$routeParams",
                             "$tgNavUrls", "$tgEvents", "$translate", LoginDirective])


#############################################################################
## Register Directive
#############################################################################

RegisterDirective = ($auth, $confirm, $location, $navUrls, $config, $analytics, $translate) ->
    link = ($scope, $el, $attrs) ->
        if not $config.get("publicRegisterEnabled")
            $location.path($navUrls.resolve("not-found"))
            $location.replace()

        $scope.data = {}
        form = $el.find("form").checksley({onlyOneErrorElement: true})

        onSuccessSubmit = (response) ->
            $analytics.trackEvent("auth", "register", "user registration", 1)

            $confirm.notify("success", $translate.instant("LOGIN_FORM.SUCCESS"))

            $location.path($navUrls.resolve("home"))

        onErrorSubmit = (response) ->
            if response.data._error_message
                text = $translate.instant("COMMON.GENERIC_ERROR", {error: response.data._error_message})
                $confirm.notify("light-error", text)

            form.setErrors(response.data)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            promise = $auth.register($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

        window.prerenderReady = true

    return {link:link}

module.directive("tgRegister", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgNavUrls", "$tgConfig",
                                "$tgAnalytics", "$translate", RegisterDirective])


#############################################################################
## Forgot Password Directive
#############################################################################

ForgotPasswordDirective = ($auth, $confirm, $location, $navUrls, $translate) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $location.path($navUrls.resolve("login"))

            text = $translate.instant("FORGOT_PASSWORD_FORM.SUCCESS")
            $confirm.success(text)

        onErrorSubmit = (response) ->
            text = $translate.instant("FORGOT_PASSWORD_FORM.ERROR")

            $confirm.notify("light-error", text)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            promise = $auth.forgotPassword($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

        window.prerenderReady = true

    return {link:link}

module.directive("tgForgotPassword", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgNavUrls", "$translate",
                                      ForgotPasswordDirective])


#############################################################################
## Change Password from Recovery Directive
#############################################################################

ChangePasswordFromRecoveryDirective = ($auth, $confirm, $location, $params, $navUrls, $translate) ->
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

            text = $translate.instant("CHANGE_PASSWORD_RECOVERY_FORM.SUCCESS")
            $confirm.success(text)

        onErrorSubmit = (response) ->
            text = $translate.instant("COMMON.GENERIC_ERROR", {error: response.data._error_message})
            $confirm.notify("light-error", text)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            promise = $auth.changePasswordFromRecovery($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgChangePasswordFromRecovery", ["$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                                  "$tgNavUrls", "$translate",
                                                  ChangePasswordFromRecoveryDirective])


#############################################################################
## Invitation
#############################################################################

InvitationDirective = ($auth, $confirm, $location, $params, $navUrls, $analytics, $translate) ->
    link = ($scope, $el, $attrs) ->
        token = $params.token

        promise = $auth.getInvitation(token)
        promise.then (invitation) ->
            $scope.invitation = invitation

        promise.then null, (response) ->
            $location.path($navUrls.resolve("login"))

            text = $translate.instant("INVITATION_LOGIN_FORM.NOT_FOUND")
            $confirm.success(text)

        # Login form
        $scope.dataLogin = {token: token}
        loginForm = $el.find("form.login-form").checksley({onlyOneErrorElement: true})

        onSuccessSubmitLogin = (response) ->
            $analytics.trackEvent("auth", "invitationAccept", "invitation accept with existing user", 1)
            $location.path($navUrls.resolve("project", {project: $scope.invitation.project_slug}))
            text = $translate.instant("INVITATION_LOGIN_FORM.SUCCESS", {
                "project_name": $scope.invitation.project_name
            })

            $confirm.notify("success", text)

        onErrorSubmitLogin = (response) ->
            text = $translate.instant("INVITATION_LOGIN_FORM.ERROR")

            $confirm.notify("light-error", text)

        submitLogin = debounce 2000, (event) =>
            event.preventDefault()

            if not loginForm.validate()
                return

            promise = $auth.acceptInvitiationWithExistingUser($scope.dataLogin)
            promise.then(onSuccessSubmitLogin, onErrorSubmitLogin)

        $el.on "submit", "form.login-form", submitLogin
        $el.on "click", ".button-login", submitLogin

        # Register form
        $scope.dataRegister = {token: token}
        registerForm = $el.find("form.register-form").checksley({onlyOneErrorElement: true})

        onSuccessSubmitRegister = (response) ->
            $analytics.trackEvent("auth", "invitationAccept", "invitation accept with new user", 1)
            $location.path($navUrls.resolve("project", {project: $scope.invitation.project_slug}))
            $confirm.notify("success", "You've successfully joined this project",
                                       "Welcome to #{_.escape($scope.invitation.project_name)}")

        onErrorSubmitRegister = (response) ->
            if response.data._error_message
                text = $translate.instant("COMMON.GENERIC_ERROR", {error: response.data._error_message})
                $confirm.notify("light-error", text)

            registerForm.setErrors(response.data)

        submitRegister = debounce 2000, (event) =>
            event.preventDefault()

            if not registerForm.validate()
                return

            promise = $auth.acceptInvitiationWithNewUser($scope.dataRegister)
            promise.then(onSuccessSubmitRegister, onErrorSubmitRegister)

        $el.on "submit", "form.register-form", submitRegister
        $el.on "click", ".button-register", submitRegister

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgInvitation", ["$tgAuth", "$tgConfirm", "$tgLocation", "$routeParams",
                                  "$tgNavUrls", "$tgAnalytics", "$translate", InvitationDirective])


#############################################################################
## Change Email
#############################################################################

ChangeEmailDirective = ($repo, $model, $auth, $confirm, $location, $params, $navUrls, $translate) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        $scope.data.email_token = $params.email_token
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            if $auth.isAuthenticated()
                $repo.queryOne("users", $auth.getUser().id).then (data) =>
                    $auth.setUser(data)
                    $location.path($navUrls.resolve("home"))
            else
                $location.path($navUrls.resolve("login"))

            text = $translate.instant("CHANGE_EMAIL_FORM.SUCCESS")
            $confirm.success(text)

        onErrorSubmit = (response) ->
            text = $translate.instant("COMMON.GENERIC_ERROR", {error: response.data._error_message})

            $confirm.notify("light-error", text)

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

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgChangeEmail", ["$tgRepo", "$tgModel", "$tgAuth", "$tgConfirm", "$tgLocation",
                                   "$routeParams", "$tgNavUrls", "$translate", ChangeEmailDirective])


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

            text = $translate.instant("CANCEL_ACCOUNT.SUCCESS")

            $confirm.success(text)

        onErrorSubmit = (response) ->
            text = $translate.instant("COMMON.GENERIC_ERROR", {error: response.data._error_message})

            $confirm.notify("error", text)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            promise = $auth.cancelAccount($scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgCancelAccount", ["$tgRepo", "$tgModel", "$tgAuth", "$tgConfirm", "$tgLocation",
                                     "$routeParams","$tgNavUrls", CancelAccountDirective])
