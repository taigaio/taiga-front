###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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

class LoginPage
    @.$inject = [
        'tgCurrentUserService',
        '$location',
        '$tgNavUrls',
        '$routeParams',
        '$tgAuth'
    ]

    constructor: (currentUserService, $location, $navUrls, $routeParams, $auth) ->
        if currentUserService.isAuthenticated()
            if not $routeParams['force_login']
                url = $navUrls.resolve("home")
                if $routeParams['next']
                    url = decodeURIComponent($routeParams['next'])
                    $location.search('next', null)

                if $routeParams['unauthorized']
                    $auth.clear()
                    $auth.removeToken()
                else
                    $location.url(url)


module.controller('LoginPage', LoginPage)

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
                 "tgThemeService",
                 "$tgAnalytics"]

    constructor: (@rootscope, @storage, @model, @rs, @http, @urls, @config, @translate, @currentUserService,
                  @themeService, @analytics) ->
        super()

        userModel = @.getUser()
        @._currentTheme = @._getUserTheme()

        @.setUserdata(userModel)

    setUserdata: (userModel) ->
        if userModel
            @.userData = Immutable.fromJS(userModel.getAttrs())
            @currentUserService.setUser(@.userData)
        else
            @.userData = null
        @analytics.setUserId()

    _getUserTheme: ->
        return @rootscope.user?.theme || @config.get("defaultTheme") || "taiga" # load on index.jade

    _setTheme: ->
        newTheme = @._getUserTheme()

        if @._currentTheme != newTheme
            @._currentTheme = newTheme
            @themeService.use(@._currentTheme)

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
        else
            @._setTheme()

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
    refresh: () ->
        url = @urls.resolve("user-me")

        return @http.get(url).then (data, status) =>
            user = data.data
            user.token = @.getUser().auth_token

            user = @model.make_model("users", user)

            @.setUser(user)
            @rootscope.broadcast("auth:refresh", user)
            return user

    login: (data, type) ->
        url = @urls.resolve("auth")

        data = _.clone(data, false)
        data.type = if type then type else "normal"

        @.removeToken()

        return @http.post(url, data).then (data, status) =>
            user = @model.make_model("users", data.data)
            @.setToken(user.auth_token)
            @.setUser(user)
            @rootscope.broadcast("auth:login", user)
            return user

    logout: ->
        @.removeToken()
        @.clear()
        @currentUserService.removeUser()

        @._setTheme()
        @._setLocales()
        @rootscope.broadcast("auth:logout")
        @analytics.setUserId()

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
            @rootscope.broadcast("auth:register", user)
            return user

    getInvitation: (token) ->
        return @rs.invitations.get(token)

    acceptInvitiationWithNewUser: (data) ->
        return @.register(data, "private", false)

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

PublicRegisterMessageDirective = ($config, $navUrls, $routeParams, templates) ->
    template = templates.get("auth/login-text.html", true)

    templateFn = ->
        publicRegisterEnabled = $config.get("publicRegisterEnabled")
        if not publicRegisterEnabled
            return ""

        url = $navUrls.resolve("register")

        if $routeParams['force_next']
            nextUrl = encodeURIComponent($routeParams['force_next'])
            url += "?next=#{nextUrl}"

        return template({url:url})

    return {
        restrict: "AE"
        scope: {}
        template: templateFn
    }

module.directive("tgPublicRegisterMessage", ["$tgConfig", "$tgNavUrls", "$routeParams",
                                             "$tgTemplate", PublicRegisterMessageDirective])


LoginDirective = ($auth, $confirm, $location, $config, $routeParams, $navUrls, $events, $translate, $window) ->
    link = ($scope, $el, $attrs) ->
        form = new checksley.Form($el.find("form.login-form"))

        if $routeParams['next'] and $routeParams['next'] != $navUrls.resolve("login")
            $scope.nextUrl = decodeURIComponent($routeParams['next'])
        else
            $scope.nextUrl = $navUrls.resolve("home")

        if $routeParams['force_next']
            $scope.nextUrl = decodeURIComponent($routeParams['force_next'])

        onSuccess = (response) ->
            $events.setupConnection()

            if $scope.nextUrl.indexOf('http') == 0
                $window.location.href = $scope.nextUrl
            else
                $location.url($scope.nextUrl)

        onError = (response) ->
            $confirm.notify("light-error", $translate.instant("LOGIN_FORM.ERROR_AUTH_INCORRECT"))

        $scope.onKeyUp = (event) ->
            target = angular.element(event.currentTarget)
            value = target.val()
            $scope.iscapsLockActivated = false
            if value != value.toLowerCase()
                $scope.iscapsLockActivated = true

        submit = debounce 2000, (event) =>
            event.preventDefault()

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
                             "$tgNavUrls", "$tgEvents", "$translate", "$window", LoginDirective])


#############################################################################
## Register Directive
#############################################################################

RegisterDirective = ($auth, $confirm, $location, $navUrls, $config, $routeParams, $analytics, $translate, $window) ->
    link = ($scope, $el, $attrs) ->
        if not $config.get("publicRegisterEnabled")
            $location.path($navUrls.resolve("not-found"))
            $location.replace()

        $scope.data = {}
        form = $el.find("form").checksley({onlyOneErrorElement: true})

        if $routeParams['next'] and $routeParams['next'] != $navUrls.resolve("login")
            $scope.nextUrl = decodeURIComponent($routeParams['next'])
        else
            $scope.nextUrl = $navUrls.resolve("home")

        onSuccessSubmit = (response) ->
            $analytics.trackEvent("auth", "register", "user registration", 1)

            if $scope.nextUrl.indexOf('http') == 0
                $window.location.href = $scope.nextUrl
            else
                $location.url($scope.nextUrl)

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
                                "$routeParams", "$tgAnalytics", "$translate", "$window", RegisterDirective])


#############################################################################
## Forgot Password Directive
#############################################################################

ForgotPasswordDirective = ($auth, $confirm, $location, $navUrls, $translate) ->
    link = ($scope, $el, $attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $location.path($navUrls.resolve("login"))

            title = $translate.instant("FORGOT_PASSWORD_FORM.SUCCESS_TITLE")
            message = $translate.instant("FORGOT_PASSWORD_FORM.SUCCESS_TEXT")

            $confirm.success(title, message)

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
            $location.path($navUrls.resolve("login"))

            text = $translate.instant("CHANGE_PASSWORD_RECOVERY_FORM.ERROR")
            $confirm.notify("light-error",text)

        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $location.path($navUrls.resolve("login"))

            text = $translate.instant("CHANGE_PASSWORD_RECOVERY_FORM.SUCCESS")
            $confirm.success(text)

        onErrorSubmit = (response) ->
            text = $translate.instant("CHANGE_PASSWORD_RECOVERY_FORM.ERROR")
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

InvitationDirective = ($auth, $confirm, $location, $config, $params, $navUrls, $analytics, $translate, config) ->
    link = ($scope, $el, $attrs) ->
        token = $params.token

        promise = $auth.getInvitation(token)
        promise.then (invitation) ->
            $scope.invitation = invitation
            $scope.publicRegisterEnabled = config.get("publicRegisterEnabled")

        promise.then null, (response) ->
            $location.path($navUrls.resolve("login"))

            text = $translate.instant("INVITATION_LOGIN_FORM.NOT_FOUND")
            $confirm.notify("light-error", text)

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
            $confirm.notify("light-error", response.data._error_message)

        submitLogin = debounce 2000, (event) =>
            event.preventDefault()

            if not loginForm.validate()
                return

            loginFormType = $config.get("loginFormType", "normal")
            data = $scope.dataLogin

            promise = $auth.login({
                username: data.username,
                password: data.password,
                invitation_token: data.token
            }, loginFormType)
            promise.then(onSuccessSubmitLogin, onErrorSubmitLogin)

        $el.on "submit", "form.login-form", submitLogin
        $el.on "click", ".button-login", submitLogin

        # Register form
        $scope.dataRegister = {token: token}
        registerForm = $el.find("form.register-form").checksley({onlyOneErrorElement: true})

        onSuccessSubmitRegister = (response) ->
            $analytics.trackEvent("auth", "invitationAccept", "invitation accept with new user", 1)
            $analytics.trackEvent("auth", "register", "user registration", 1)

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

module.directive("tgInvitation", ["$tgAuth", "$tgConfirm", "$tgLocation", "$tgConfig", "$routeParams",
                                  "$tgNavUrls", "$tgAnalytics", "$translate", "$tgConfig", InvitationDirective])


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
                    $location.replace()
            else
                $location.path($navUrls.resolve("login"))
                $location.replace()

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
