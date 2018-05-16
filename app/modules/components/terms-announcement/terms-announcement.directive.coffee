###
# Copyright (C) 2014-2015 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2015 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2015 David Barragán Merino <bameda@dbarragan.com>
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
# File: terms-announcement.directive.coffee
###


TermsAnnouncementDirective = (TermsAnnouncementService, $repo, $auth) ->
    link = (scope, el, attrs) ->

    return {
        restrict: "AE",
        scope: {},
        controllerAs: 'vm',
        controller: () ->
            this.close = () ->
                TermsAnnouncementService.open = false
                user = $auth.getUser()

                onSuccess = (data) =>
                    $auth.setUser(data)

                user.read_new_terms = true
                $repo.save(user).then(onSuccess)

            Object.defineProperties(this, {
                open: {
                    get: () -> return TermsAnnouncementService.open
                },
                title: {
                    get: () -> return TermsAnnouncementService.title
                },
                desc: {
                    get: () -> return TermsAnnouncementService.desc
                }
            })
        link: link,
        templateUrl: "components/terms-announcement/terms-announcement.html"
    }

TermsAnnouncementDirective.$inject = [
    "tgTermsAnnouncementService",
    "$tgRepo",
    "$tgAuth"
]

angular.module("taigaComponents")
    .directive("tgTermsAnnouncement", TermsAnnouncementDirective)
