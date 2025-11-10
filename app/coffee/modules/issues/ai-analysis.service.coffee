###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class AiAnalysisService extends taiga.Service
    @.$inject = [
        "$q",
        "$http",
        "$tgConfig",
        "$timeout"
    ]

    constructor: (@q, @http, @config, @timeout) ->
        @.apiUrl = "#{@config.get('api')}/issues/ai-analyze"

    analyzeIssues: (projectId, issues) ->
        deferred = @q.defer()

        # TODO: Replace with actual API call when backend is ready
        # Example API implementation:
        # @http.post(@.apiUrl, {
        #     project_id: projectId,
        #     issue_ids: _.map(issues, (issue) -> issue.id),
        #     issues: @._formatIssuesForApi(issues)
        # }).then (response) =>
        #     deferred.resolve(response.data.results)
        # .catch (error) =>
        #     deferred.reject(error)

        @timeout =>
            results = @._generateMockAnalysis(issues)
            deferred.resolve(results)
        , 1500

        return deferred.promise

    _formatIssuesForApi: (issues) ->
        return _.map issues, (issue) ->
            return {
                id: issue.id,
                ref: issue.ref,
                subject: issue.subject,
                description: issue.description or "",
                type: issue.type?.name or "",
                priority: issue.priority?.name or "",
                severity: issue.severity?.name or "",
                status: issue.status?.name or "",
                tags: issue.tags or []
            }

    _generateMockAnalysis: (issues) ->
        priorities = ["Low", "Normal", "High"]
        types = ["Bug", "Question", "Enhancement"]
        severities = ["Wishlist", "Minor", "Normal", "Important", "Critical"]
        
        modules = [
            "Frontend - Kanban Module",
            "Backend - API Layer",
            "Database Layer",
            "Drag & Drop Component",
            "Event Handling",
            "Authentication System",
            "Permission System",
            "Notification Module"
        ]

        solutions = [
            "Check component version compatibility",
            "Verify event listeners are properly bound",
            "Review browser console for error logs",
            "Test behavior across different browsers",
            "Check database query performance",
            "Optimize frontend rendering logic",
            "Add exception handling and error logging",
            "Update related dependencies to latest version",
            "Add unit test coverage for this scenario",
            "Consult official documentation for best practices"
        ]

        return _.map issues, (issue) =>
            priority = priorities[Math.floor(Math.random() * priorities.length)]
            type = types[Math.floor(Math.random() * types.length)]
            severity = severities[Math.floor(Math.random() * severities.length)]
            
            numModules = 2 + Math.floor(Math.random() * 3)
            selectedModules = @._shuffleArray(modules).slice(0, numModules)
            
            numSolutions = 3 + Math.floor(Math.random() * 3)
            selectedSolutions = @._shuffleArray(solutions).slice(0, numSolutions)

            description = @._generateMockDescription(issue, type, priority)

            return {
                issueId: issue.id,
                issueRef: "##{issue.ref}",
                subject: issue.subject,
                analysis: {
                    priority: priority,
                    priorityReason: @._getPriorityReason(priority),
                    type: type,
                    severity: severity,
                    description: description,
                    relatedModules: selectedModules,
                    solutions: selectedSolutions,
                    confidence: (0.7 + Math.random() * 0.25).toFixed(2)
                }
            }

    _generateMockDescription: (issue, type, priority) ->
        descriptions = {
            "Bug": [
                "This is a #{priority.toLowerCase()} priority defect that may be " +
                "related to code logic errors or third-party library compatibility.",
                "Based on the issue description, this bug may impact user " +
                "experience and should be addressed accordingly.",
                "Analysis suggests this issue could be caused by improper " +
                "event handling or state management."
            ],
            "Question": [
                "This is a technical inquiry. Consider consulting relevant " +
                "documentation or seeking help from team members.",
                "This question may require clarification of requirements or " +
                "technical details.",
                "Recommend discussing within the team to find the best solution."
            ],
            "Enhancement": [
                "This feature enhancement could improve the product's " +
                "user experience.",
                "This enhancement has good compatibility with existing systems " +
                "and relatively low implementation risk.",
                "Suggest evaluating cost-benefit ratio and adjusting priority " +
                "based on user needs."
            ]
        }
        
        typeDescriptions = descriptions[type] or descriptions["Bug"]
        selectedDesc = typeDescriptions[Math.floor(Math.random() * typeDescriptions.length)]
        
        return "Analysis: #{selectedDesc} Issue: '#{issue.subject}'"

    _getPriorityReason: (priority) ->
        reasons = {
            "Low": "Limited impact, does not affect core functionality",
            "Normal": "Regular issue, handle as scheduled",
            "High": "Affects core functionality or user experience, should prioritize"
        }
        return reasons[priority] or "Needs evaluation to determine handling priority"

    _shuffleArray: (array) ->
        newArray = array.slice()
        for i in [newArray.length - 1..1] by -1
            j = Math.floor(Math.random() * (i + 1))
            [newArray[i], newArray[j]] = [newArray[j], newArray[i]]
        return newArray

angular.module("taigaIssues").service("tgAiAnalysisService", AiAnalysisService)
