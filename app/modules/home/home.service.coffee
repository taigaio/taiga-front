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
# File: home/home.service.coffee
###

groupBy = @.taiga.groupBy

class HomeService extends taiga.Service
    @.$inject = [
        "$tgNavUrls",
        "tgResources",
        "tgProjectsService"
    ]

    constructor: (@navurls, @rs, @projectsService) ->

    _attachProjectInfoToWorkInProgress: (workInProgress, projectsById) ->
        _attachProjectInfoToDuty = (duty, objType) =>
            project = projectsById.get(String(duty.get('project')))

            ctx = {
                project: project.get('slug')
                ref: duty.get('ref')
            }

            url = @navurls.resolve("project-#{objType}-detail", ctx)

            duty = duty.set('url', url)
            duty = duty.set('project', project)
            duty = duty.set("_name", objType)

            return duty

        _getValidDutiesAndAttachProjectInfo = (duties, dutyType)->
            # Exclude duties where I'm not member of the project
            duties = duties.filter((duty) ->
                return projectsById.get(String(duty.get('project'))))

            duties = duties.map (duty) ->
                return _attachProjectInfoToDuty(duty, dutyType)

            return duties

        assignedTo = workInProgress.get("assignedTo")

        if assignedTo.get("epics")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("epics"), "epics")
            assignedTo = assignedTo.set("epics", _duties)

        if assignedTo.get("userStories")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("userStories"), "userstories")
            assignedTo = assignedTo.set("userStories", _duties)

        if assignedTo.get("tasks")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("tasks"), "tasks")
            assignedTo = assignedTo.set("tasks", _duties)

        if assignedTo.get("issues")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("issues"), "issues")
            assignedTo = assignedTo.set("issues", _duties)


        watching = workInProgress.get("watching")

        if watching.get("epics")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("epics"), "epics")
            watching = watching.set("epics", _duties)

        if watching.get("userStories")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("userStories"), "userstories")
            watching = watching.set("userStories", _duties)

        if watching.get("tasks")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("tasks"), "tasks")
            watching = watching.set("tasks", _duties)

        if watching.get("issues")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("issues"), "issues")
            watching = watching.set("issues", _duties)

        workInProgress = workInProgress.set("assignedTo", assignedTo)
        workInProgress = workInProgress.set("watching", watching)

    getWorkInProgress: (userId) ->
        projectsById = Immutable.Map()

        projectsPromise = @projectsService.getProjectsByUserId(userId).then (projects) ->
            projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

        assignedTo = Immutable.Map()

        params_epics = {
            status__is_closed: false
            assigned_to: userId
        }

        params_uss = {
            is_closed: false
            assigned_users: userId
        }

        params_tasks = {
            status__is_closed: false
            assigned_to: userId
        }

        params_issues = {
            status__is_closed: false
            assigned_to: userId
        }

        assignedEpicsPromise = @rs.epics.listInAllProjects(params_epics).then (epics) ->
            assignedTo = assignedTo.set("epics", epics)

        assignedUserStoriesPromise = @rs.userstories.listInAllProjects(params_uss).then (userstories) ->
            assignedTo = assignedTo.set("userStories", userstories)

        assignedTasksPromise = @rs.tasks.listInAllProjects(params_tasks).then (tasks) ->
            assignedTo = assignedTo.set("tasks", tasks)

        assignedIssuesPromise = @rs.issues.listInAllProjects(params_issues).then (issues) ->
            assignedTo = assignedTo.set("issues", issues)

        params_epics = {
            status__is_closed: false
            watchers: userId
        }

        params_uss = {
            is_closed: false
            watchers: userId
        }

        params_tasks = {
            status__is_closed: false
            watchers: userId
        }

        params_issues = {
            status__is_closed: false
            watchers: userId
        }

        watching = Immutable.Map()

        watchingEpicsPromise = @rs.epics.listInAllProjects(params_epics).then (epics) ->
            watching = watching.set("epics", epics)

        watchingUserStoriesPromise = @rs.userstories.listInAllProjects(params_uss).then (userstories) ->
            watching = watching.set("userStories", userstories)

        watchingTasksPromise = @rs.tasks.listInAllProjects(params_tasks).then (tasks) ->
            watching = watching.set("tasks", tasks)

        watchingIssuesPromise = @rs.issues.listInAllProjects(params_issues).then (issues) ->
            watching = watching.set("issues", issues)

        workInProgress = Immutable.Map()

        Promise.all([
            projectsPromise,
            assignedEpicsPromise,
            watchingEpicsPromise,
            assignedUserStoriesPromise,
            watchingUserStoriesPromise,
            assignedTasksPromise,
            watchingTasksPromise,
            assignedIssuesPromise,
            watchingIssuesPromise
        ]).then =>
            workInProgress = workInProgress.set("assignedTo", assignedTo)
            workInProgress = workInProgress.set("watching", watching)

            workInProgress = @._attachProjectInfoToWorkInProgress(workInProgress, projectsById)

            return workInProgress

angular.module("taigaHome").service("tgHomeService", HomeService)
