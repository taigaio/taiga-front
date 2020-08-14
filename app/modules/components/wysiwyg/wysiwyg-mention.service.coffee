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
# File: components/wysiwyg/wysiwyg-mention.service.coffee
###

class WysiwygMentionService
    @.$inject = [
        "tgProjectService",
        "tgWysiwygService",
        "$tgNavUrls",
        "$tgResources",
        "$q"
    ]

    constructor: (@projectService, @wysiwygService, @navurls, @rs, @q) ->
        @.cancelablePromise = null
        @.projectSlug = @projectService.project.get('slug')

    search: (mention) ->
        return @q (resolve) =>
            if '#'.indexOf(mention[0]) != -1
                @.searchItem(mention.replace('#', '')).then(resolve)
            else if '@'.indexOf(mention[0]) != -1
                @.searchUser(mention.replace('@', ''), resolve)
            else if ':'.indexOf(mention[0]) != -1
                @.searchEmoji(mention.replace(':', ''), resolve)

    searchItem: (term) ->
        return @q (resolve, reject) =>
            term = taiga.slugify(term)

            filter = (item) ->
                return ['subject', 'ref'].some((attr) ->
                    taiga.slugify(item[attr]).indexOf(term) >= 0
                )

            @rs.search.do(@projectService.project.get('id'), term).then (res) =>
                result = []
                if !res.count or res.count == res.wikipages.length
                    resolve(result)
                else
                    typeURLs = {
                        issues: 'project-issues-detail'
                        userstories: 'project-userstories-detail'
                        tasks: 'project-tasks-detail'
                    }

                    for type in ['issues', 'tasks', 'userstories']
                        if not res[type]
                            continue
                        items = res[type].filter(filter).map (item) =>
                            item.url = @navurls.resolve(typeURLs[type], {
                                project: @.projectSlug,
                                ref: item.ref
                            })
                            return item
                        result = result.concat(items)
                    resolve(_.sortBy(result, ["ref"]).slice(0, 10))

    searchUser: (term, callback) ->
        users = @projectService.project.toJS().members.filter (user) ->
            return ['username', 'full_name', 'full_name_display'].some((attr) ->
                taiga.slugify(user[attr]).indexOf(term) >= 0 || user[attr].indexOf(term) >= 0
            )

        users = users.slice(0, 10).map (item) =>
            item.url = @navurls.resolve('user-profile', {
                project: @.projectSlug,
                username: item.username
            })
            return item

        callback(users)

    searchEmoji: (name, callback) ->
        filteredEmojis = @wysiwygService.searchEmojiByName(name)
        filteredEmojis = filteredEmojis.slice(0, 10)

        callback(filteredEmojis)

angular.module("taigaComponents").service("tgWysiwygMentionService", WysiwygMentionService)
