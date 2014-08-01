taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaProject")

CreateProject = ($repo, $confirm, $location, $navurls, $rs) ->
    link = ($scope, $el, attrs) ->
        $scope.data = {}
        $scope.templates = []
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
            $el.addClass("hidden")

            $confirm.notify("success", "Success") #TODO: i18n

            url = $navurls.resolve('project')
            fullUrl = $navurls.formatUrl(url, {'project': response.slug})

            $location.url(fullUrl)

        onErrorSubmit = (response) ->
            $confirm.notify("light-error", "According to our Oompa Loompas, project name is
                                            already in use.") #TODO: i18n

        submit = ->
            if not form.validate()
                return

            promise = $repo.create("projects", $scope.data)
            promise.then(onSuccessSubmit, onErrorSubmit)

        $scope.$on "projects:create", ->
            $scope.data = {}

            if !$scope.templates.length
                $rs.projects.templates()
                    .then (result) =>
                        $scope.templates = _.map(result, (item) -> {"id": item.id, "name": item.name})

            $el.removeClass("hidden")

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", "a.button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbCreateProject", [
    "$tgRepo",
    "$tgConfirm",
    "$location",
    "$tgNavUrls",
    "$tgResources",
    CreateProject
])
