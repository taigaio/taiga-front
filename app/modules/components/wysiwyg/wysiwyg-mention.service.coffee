###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
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
# File: modules/components/wysiwyg/wysiwyg-mention.service.coffee
###

class WysiwygMentionService
    @.$inject = [
        "tgProjectService",
        "tgWysiwygService",
        "$tgNavUrls",
        "$tgResources"
    ]

    constructor: (@projectService, @wysiwygService, @navurls, @rs) ->
        @.cancelablePromise = null

    searchEmoji: (name, cb) ->
        filteredEmojis = @wysiwygService.searchEmojiByName(name)
        filteredEmojis = filteredEmojis.slice(0, 10)

        cb(filteredEmojis)

    searchUser: (term, cb) ->
        searchProps = ['username', 'full_name', 'full_name_display']

        users = @projectService.project.toJS().members.filter (user) =>
            for prop in searchProps
                if taiga.slugify(user[prop]).indexOf(term) >= 0
                    return true
            return false

         users = users.slice(0, 10).map (it) =>
            it.url = @navurls.resolve('user-profile', {
                project: @projectService.project.get('slug'),
                username: it.username
            })

            return it

        cb(users)

    searchItem: (term) ->
        return new Promise (resolve, reject) =>
            term = taiga.slugify(term)

            searchTypes = ['issues', 'tasks', 'userstories']

            urls = {
                issues: "project-issues-detail",
                tasks: "project-tasks-detail",
                userstories: "project-userstories-detail"
            }

            searchProps = ['ref', 'subject']

            filter = (item) =>
                for prop in searchProps
                    if taiga.slugify(item[prop]).indexOf(term) >= 0
                        return true
                return false

            @.cancelablePromise.abort() if @.cancelablePromise

            @.cancelablePromise = @rs.search.do(@projectService.project.get('id'), term)

            @.cancelablePromise.then (res) =>
                # ignore wikipages if they're the only results. can't exclude them in search
                if res.count < 1 or res.count == res.wikipages.length
                    resolve([])
                else
                    result = []
                    for type in searchTypes
                        if res[type] and res[type].length > 0
                            items = res[type].filter(filter)
                            items = items.map (it) =>
                                it.url = @navurls.resolve(urls[type], {
                                    project: @projectService.project.get('slug'),
                                    ref: it.ref
                                })

                                return it

                            result = result.concat(items)

                    resolve(result.slice(0, 10))


    search: (mention) ->
        return new Promise (resolve) =>
            if '#'.indexOf(mention[0]) != -1
                @.searchItem(mention.replace('#', '')).then(resolve)
            else if '@'.indexOf(mention[0]) != -1
                @.searchUser(mention.replace('@', ''), resolve)
            else if ':'.indexOf(mention[0]) != -1
                @.searchEmoji(mention.replace(':', ''), resolve)


angular.module("taigaComponents").service("tgWysiwygMentionService", WysiwygMentionService)
