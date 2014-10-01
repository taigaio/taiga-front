taiga = @.taiga

groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
mixOf = @.taiga.mixOf
debounce = @.taiga.debounce
trim = @.taiga.trim

module = angular.module("taigaFeedback", [])

FeedbackDirective = ($lightboxService, $navurls, $location, $route)->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        project = null

        submit = debounce 2000, ->
            if not form.validate()
                return

        $scope.$on "feedback:show", (ctx, newProject)->
            project = newProject

            $scope.$apply ->
                $scope.issueTypes = _.sortBy(project.issue_types, "order")

                $scope.feedback = {
                    project: project.id
                    type: project.default_issue_type
                }

            $lightboxService.open($el)
            $el.find("textarea").focus()

        $el.on "submit", (event) ->
            submit()

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgFeedback", ["lightboxService", "$tgNavUrls", "$tgLocation", "$route", FeedbackDirective])
