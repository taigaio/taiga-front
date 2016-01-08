###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/issues/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaUserSettings")


#############################################################################
## Delete User Lightbox Directive
#############################################################################

DeleteUserDirective = ($repo, $rootscope, $auth, $location, $navUrls, lightboxService) ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "deletelightbox:new", (ctx, user)->
            lightboxService.open($el)

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            promise = $repo.remove($scope.user)

            promise.then (data) ->
                lightboxService.close($el)
                $auth.logout()
                $location.path($navUrls.resolve("login"))

            # FIXME: error handling?
            promise.then null, ->
                console.log "FAIL"

        $el.on "click", ".button-red", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $el.on "click", ".button-green", debounce 2000, (event) ->
            event.preventDefault()
            submit()

    return {
        link: link,
        templateUrl: "user/lightbox/lightbox-delete-account.html"
    }

module.directive("tgLbDeleteUser", ["$tgRepo", "$rootScope", "$tgAuth", "$tgLocation", "$tgNavUrls",
                                    "lightboxService", DeleteUserDirective])
