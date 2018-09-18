###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/terms-announcement/terms-announcement.directive.coffee
###


TermsAnnouncementDirective = (TermsAnnouncementService, $repo, $auth, $config, $model) ->
    link = (scope, el, attrs) ->
        scope.privacyPolicyUrl = $config.get("privacyPolicyUrl")
        scope.termsOfServiceUrl = $config.get("termsOfServiceUrl")
        scope.GDPRUrl = $config.get("GDPRUrl")

    return {
        restrict: "AE",
        scope: {},
        controllerAs: 'vm',
        controller: () ->
            this.close = () ->
                TermsAnnouncementService.open = false
                user = $auth.getUser()

                # We need to force initialization of rootscope user if localstorage user
                # doesn't have the 'read_new_terms' key
                if user.read_new_terms == undefined
                    userData = user.getAttrs()
                    userData.read_new_terms = false
                    user = $model.make_model("users", userData)

                user.read_new_terms = true

                onSuccess = (data) ->
                    $auth.setUser(data)

                $repo.save(user).then(onSuccess)

            Object.defineProperties(this, {
                open: {
                    get: () -> return TermsAnnouncementService.open
                }
            })
        link: link,
        templateUrl: "components/terms-announcement/terms-announcement.html"
    }

TermsAnnouncementDirective.$inject = [
    "tgTermsAnnouncementService",
    "$tgRepo",
    "$tgAuth",
    "$tgConfig",
    "$tgModel"
]

angular.module("taigaComponents")
    .directive("tgTermsAnnouncement", TermsAnnouncementDirective)
