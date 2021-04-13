taiga = @.taiga

generateHash = @.taiga.generateHash

WorkingOnDirective = (homeService, currentUserService, storage) ->
        
    link = (scope, el, attrs, ctrl) ->
        updateShowHiddenDuties = (slot) ->
            hash = generateHash(['ShowHiddenDashboardDuties', slot])
            return storage.set(hash, scope.showHiddenDuties[slot])

        getShowHiddenDuties = (slot) ->
            hash = generateHash(['ShowHiddenDashboardDuties', slot])
            return storage.get(hash) or false

        updateHiddenDuties = (slot) ->
            hash = generateHash(['HiddenDashboardDuties', slot])
            return storage.set(hash, scope.hiddenDuties[slot])

        getHiddenDuties = (slot) ->
            hash = generateHash(['HiddenDashboardDuties', slot])
            return storage.get(hash) or []

        toggleDutyHidden = (duty, slot) ->
            if duty.get('id') in scope.hiddenDuties[slot]
                scope.hiddenDuties[slot].splice(scope.hiddenDuties[slot].indexOf(duty.get('id')), 1)
            else
                scope.hiddenDuties[slot].push(duty.get('id'))
            updateHiddenDuties(slot)
            scope.$apply()

        user = currentUserService.getUser()
        # If we are not logged in the user will be null
        if !user
            return

        userId = user.get("id")
        ctrl.getWorkInProgress(userId)

        slots = ['working-on', 'watching']

        scope.hiddenDuties = {}
        scope.showHiddenDuties = {}

        scope.toggleShowHiddenDuties = (slot) ->
            if !(slot in slots)
                return console.error("Invalid duties slot `#{slot}`")
            scope.showHiddenDuties[slot] = !scope.showHiddenDuties[slot]
            updateShowHiddenDuties(slot)

        for slot in slots
            scope.hiddenDuties[slot] =  getHiddenDuties(slot)
            scope.showHiddenDuties[slot] =  getShowHiddenDuties(slot)

        scope.$on "duty:toggle-hidden", (event, duty, slot) =>
            if !(slot in slots)
                return console.error("Invalid duties slot `#{slot}`")
            toggleDutyHidden(duty, slot)

    return {
        controller: "WorkingOn",
        controllerAs: "vm",
        templateUrl: "home/working-on/working-on.html",
        scope: {},
        link: link
    }

WorkingOnDirective.$inject = [
    "tgHomeService",
    "tgCurrentUserService",
    "$tgStorage"
]

angular.module("taigaHome").directive("tgWorkingOn", WorkingOnDirective)
