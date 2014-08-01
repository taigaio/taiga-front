taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaProject")

CreateProject = ($repo, $confirm, $location, $navurls) ->
    link = ($scope, $el, attrs) ->
        $scope.data = {}
        form = $el.find("form").checksley()

        onSuccessSubmit = (response) ->
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
            $el.removeClass("hidden")

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", "a.button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgLbCreateProject", ["$tgRepo", "$tgConfirm", "$location", "$tgNavUrls", CreateProject])
