###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaCommon")

#############################################################################
## UserStory status Directive (popover for change status)
#############################################################################

UsStatusDirective = ($repo, $template) ->
    ###
    Print the status of a US and a popover to change it.
    - tg-us-status: The user story
    - on-update: Method call after US is updated

    Example:

      div.status(tg-us-status="us" on-update="ctrl.loadSprintState()")
        a.us-status(href="", title="Status Name")

    NOTE: This directive need 'usStatusById' and 'project'.
    ###
    template = $template.get("common/popover/popover-us-status.html", true)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        render = (us) ->
            usStatusDomParent = $el.find(".us-status")
            usStatusDom = $el.find(".us-status .us-status-bind")
            usStatusById = $scope.usStatusById

            if usStatusById[us.status]
                usStatusDom.text(usStatusById[us.status].name)
                usStatusDomParent.css("color", usStatusById[us.status].color)

        $el.on "click", ".us-status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $el.find(".pop-status").popover().open()

        $el.on "click", ".popover-status", debounce 2000, (event) ->
            event.preventDefault()
            event.stopPropagation()

            statusElement = $(event.currentTarget).find('#js-status-btn')

            target = angular.element(statusElement)

            us = $scope.$eval($attrs.tgUsStatus)
            us.status = target.data("status-id")
            render(us)

            $el.find(".pop-status").popover().close()

            $scope.$apply () ->
                $repo.save(us).then ->
                    $scope.$eval($attrs.onUpdate)


        $scope.$on("userstories:loaded", -> render($scope.$eval($attrs.tgUsStatus)))
        $scope.$on("$destroy", -> $el.off())

        # Bootstrap
        us = $scope.$eval($attrs.tgUsStatus)
        render(us)

        bindOnce $scope, "project", (project) ->
            html = template({
                "statuses": project.us_statuses,
                "currentStatus": us.status
            })
            $el.append(html)

            # If the user has not enough permissions the click events are unbinded
            if $scope.project.my_permissions.indexOf("modify_us") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")


    return {link: link}

module.directive("tgUsStatus", ["$tgRepo", "$tgTemplate", UsStatusDirective])

#############################################################################
## Related Task Status Directive
#############################################################################

RelatedTaskStatusDirective = ($repo, $template) ->
    ###
    Print the status of a related task and a popover to change it.
    - tg-related-task-status: The related task
    - on-update: Method call after US is updated

    Example:

      div.status(tg-related-task-status="task" on-update="ctrl.loadSprintState()")
        a.task-status(href="", title="Status Name")

    NOTE: This directive need 'taskStatusById' and 'project'.
    ###
    selectionTemplate = $template.get("common/popover/popover-related-task-status.html", true)

    updateTaskStatus = ($el, task, taskStatusById) ->
        taskStatusDomParent = $el.find(".us-status")
        taskStatusDom = $el.find(".task-status .task-status-bind")

        if taskStatusById[task.status]
            taskStatusDom.text(taskStatusById[task.status].name)
            taskStatusDomParent.css('color', taskStatusById[task.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        task = $scope.$eval($attrs.tgRelatedTaskStatus)
        notAutoSave = $scope.$eval($attrs.notAutoSave)
        autoSave = !notAutoSave

        $el.on "click", ".task-status", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-status").popover().open()

            # pop = $el.find(".pop-status")
            # popoverService.open(pop)

        $el.on "click", ".status", debounce 2000, (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            task.status = target.data("status-id")
            $el.find(".pop-status").popover().close()
            updateTaskStatus($el, task, $scope.taskStatusById)

            if autoSave
                $scope.$apply () ->
                    $repo.save(task).then ->
                        $scope.$eval($attrs.onUpdate)
                        $scope.$emit("related-tasks:status-changed")

        $scope.$watch $attrs.tgRelatedTaskStatus, () ->
            task = $scope.$eval($attrs.tgRelatedTaskStatus)
            updateTaskStatus($el, task, $scope.taskStatusById)

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.task_statuses }))
            updateTaskStatus($el, task, $scope.taskStatusById)

            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_task") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTaskStatus", ["$tgRepo", "$tgTemplate", RelatedTaskStatusDirective])

#############################################################################
## jQuery plugin for Popover
#############################################################################

$.fn.popover = () ->
    $el = @

    isVisible = () =>
        $el.css({
            "display": "block",
            "visibility": "hidden"
        })

        docViewTop = $(window).scrollTop()
        docViewBottom = docViewTop + $(window).height()

        docViewWidth = $(window).width()
        docViewRight = docViewWidth
        docViewLeft = 0

        elemTop = $el.offset().top
        elemBottom = elemTop + $el.height()

        elemWidth = $el.width()
        elemLeft = $el.offset().left
        elemRight = $el.offset().left + elemWidth

        $el.css({
            "display": "none",
            "visibility": "visible"
        })

        return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop) && (elemLeft >= docViewLeft) && (elemRight <= docViewRight))

    closePopover = (onClose) =>
        if onClose then onClose.call($el)

        $el.fadeOut () =>
            $el
                .removeClass("active")
                .removeClass("fix")

        $el.off("popup:close")


    closeAll = () =>
        $(".popover.active").each () ->
            $(this).trigger("popup:close")

    open = (onClose) =>
        if $el.hasClass("active")
            close()
        else
            closeAll()

            if !isVisible()
                $el.addClass("fix")

            $el.fadeIn () =>
                $el.addClass("active")
                $(document.body).off("popover")

                $(document.body).one "click.popover", () =>
                    closeAll()

            $el.on "popup:close", (e) => closePopover(onClose)

    close = () =>
        $el.trigger("popup:close")

    return {open: open, close: close, closeAll: closeAll}

# Example:
#
# taiga.globalPopover(el, [
#     {
#         text: 'Button text',
#         event: () ->
#             console.log('button clicked')
#     }
# ], {
#     width: 170,
#     paddingTop: 10,
#     paddingLeft: 5
# }, () -> onClosePopover())

taiga.globalPopover = (target, list, options = {}, cb) ->
    wrapper = document.createElement('div')
    wrapper.classList.add('popover', 'global-popover')
    ul = document.createElement('ul')

    createSvg = (icon) ->
        tgSvg = document.createElement('tg-svg')
        svg = document.createElement('svg')
        use = document.createElement('use')

        xlink = document.createAttribute('xlink:href')
        xlink.value = '#' + icon

        attrHref = document.createAttribute('attr-href')
        attrHref.value = '#' + icon

        use.setAttributeNode(xlink)
        use.setAttributeNode(attrHref)

        svg.classList.add('icon')
        svg.appendChild(use)
        tgSvg.appendChild(svg)

        return tgSvg

    close = () ->
        $(wrapper).popover().close()
        $(wrapper).remove()

    followElement = () ->
        elementPosition()
        requestAnimationFrame(followElement)

    elementPosition = () ->
        rect = target.getBoundingClientRect()
        top = rect.top + rect.height
        width = options.width || 170
        left = rect.right - width

        if options.paddingTop
            top = top + options.paddingTop

        if options.paddingLeft
            left = left + options.paddingLeft

        wrapper.style.top = top + 'px'
        wrapper.style.left = left + 'px'
        wrapper.style.width = width + 'px'

    elementPosition()
    followElement()

    document.addEventListener('scroll', close, true)

    list.forEach (option) ->
        li = document.createElement('li')
        button = document.createElement('button')
        button.addEventListener('click', option.event)

        if option.icon
            button.innerHTML = createSvg(option.icon).innerHTML

        button.appendChild(document.createTextNode(option.text))
        li.appendChild(button)
        ul.appendChild(li)

    wrapper.appendChild(ul)
    document.body.appendChild(wrapper)

    $(wrapper).popover().open () ->
        document.removeEventListener('scroll', close)

        cb()

        if wrapper
            setTimeout () ->
                $(wrapper).remove()
            , 2000

    return () =>
        $(wrapper).popover().close()
