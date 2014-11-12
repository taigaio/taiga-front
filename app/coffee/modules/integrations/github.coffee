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
# File: modules/integrations/github.coffee
###

taiga = @.taiga

module = angular.module("taigaIntegrations")

AUTH_URL = "https://github.com/login/oauth/authorize"


#############################################################################
## User story team requirements button directive
#############################################################################

GithubLoginButtonDirective = ($window, $params, $location, $config, $events, $confirm, $auth, $navUrls, $loader) ->
    # Login or registar a user with his/her github account.
    #
    # Example:
    #     tg-github-login-button()
    #
    # Requirements:
    #   - ...

    template = """
    <a class="button button-github" href="" title="Enter with your github account">
        <span class="icon icon-github"></span>
        <span>Login with Github</span>
    </a>
    """ #TODO: i18n

    link = ($scope, $el, $attrs) ->
        clientId = $config.get("gitHubClientId", null)
        return if not clientId

        renderGitHubButton = ->
            $el.html(template) if clientId

        loginOnSuccess = (response) ->
            if $params.next and $params.next != $navUrls.resolve("login")
                nextUrl = $params.next
            else
                nextUrl = $navUrls.resolve("home")

            $events.setupConnection()

            $location.search("next", null)
            $location.search("token", null)
            $location.search("state", null)
            $location.search("code", null)
            $location.path(nextUrl)

        loginOnError = (response) ->
            $location.search("state", null)
            $location.search("code", null)
            $loader.pageLoaded()

            if response.data.error_message
                $confirm.notify("light-error", response.data.error_message )
            else
                $confirm.notify("light-error", "Our Oompa Loompas have not been able to get you
                                                credentials from GitHub.")  #TODO: i18n

        loginWithGitHubAccount = ->
            type = $params.state
            code = $params.code
            token = $params.token

            return if not (type == "github" and code)
            $loader.start()

            data = {code: code, token: token}
            $auth.login(data, type).then(loginOnSuccess, loginOnError)

        renderGitHubButton()
        loginWithGitHubAccount()

        $el.on "click", ".button-github", (event) ->
            redirectToUri = $location.absUrl()
            url = "#{AUTH_URL}?client_id=#{clientId}&redirect_uri=#{redirectToUri}&state=github&scope=user:email"
            $window.location.href = url

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        template: ""
    }

module.directive("tgGithubLoginButton", ["$window", '$routeParams', "$tgLocation", "$tgConfig", "$tgEvents",
                                         "$tgConfirm", "$tgAuth", "$tgNavUrls", "tgLoader",
                                         GithubLoginButtonDirective])
