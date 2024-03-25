###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

# cp -r node_modules/taiga-html-editor/packages/ckeditor5-build-classic/build/translations ../taiga-front/extras

taiga = @.taiga

Wysiwyg = ($translate, $confirm, $storage, wysiwygService, animationFrame, tgLoader, analytics, $location, $attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        isEditOnly = !!$attrs.$attr.editonly
        notPersist = !!$attrs.$attr.notPersist

        if $scope.editonly != undefined
            isEditOnly = $scope.editonly

        $scope.required = !!$attrs.$attr.required
        $scope.editMode = isEditOnly || false
        $scope.mode = localStorage.getItem('editor-mode') || 'html'

        if $scope.mode != 'html' && $scope.mode != 'markdown'
            $scope.mode = 'html'

        $scope.markdown = ''
        $scope.html = ''
        textEditor = null
        pageAttachments = $attachmentsFullService.attachments.toJS()
        editorLinks = []


        linksEvents = () ->
            initialPos = null

            $el.on 'mousedown', '.js-wysiwyg-html', (e) =>
                initialPos = {x: e.clientX, y: e.clientY}

            $el.on 'click', '.js-wysiwyg-html', (e) =>
                diffX = Math.abs(e.clientX - initialPos.x)
                diffY = Math.abs(e.clientY - initialPos.y)

                initialPos = null

                if diffX > 10 || diffY > 10
                    return

                if e.target.tagName != 'A' && e.target.parentElement.tagName != 'A'
                    $scope.$applyAsync () => $scope.setEditMode(true)

            editorLinks = textEditor.querySelectorAll('a[target="_blank"]:not(.link-event)')

            if editorLinks.length
                editorLinks.forEach (link) =>
                    link.classList.add('link-event')

                    # prevent ckeditor change to edit mode
                    link.addEventListener 'mousedown', (e) =>
                        if !$scope.editMode
                            e.preventDefault()
                            e.stopPropagation()

                    link.addEventListener 'click', (e) =>
                        if !$scope.editMode
                            window.open(e.currentTarget.getAttribute('href'), '_blank');

        unwatchContent = $scope.$watch 'content', (content) ->
            if !_.isUndefined(content)
                $scope.outdated = isOutdated()

                if ($scope.markdown.length || content.length) && $scope.markdown == content
                    return

                content = getCurrentContent()

                $scope.markdown = content

                if tgLoader.open()
                    unwatchLoader = tgLoader.onEnd () ->
                        $scope.$evalAsync () ->
                            create(content)
                            unwatchLoader()
                else
                    create(content)

                unwatchContent()

        create = (text) =>
            if textEditor
                return

            textEditor = document.createElement('tg-text-editor')
            textEditor.projectId = $scope.project.id
            textEditor.projectSlug = $scope.project.slug
            textEditor.placeholder = $scope.placeholder
            setHtmlEditor(text)
            textEditor.mode = $scope.mode
            textEditor.lan = $translate.preferredLanguage()
            textEditor.uploadFunction = $scope.onUploadFile
            textEditor.members = $scope.project.members.map (member) =>
                return Object.assign(member, {
                    fullNameDisplay: member.full_name_display
                })

            $scope.$applyAsync () => linksEvents()

            if isDraft()
                $scope.setEditMode(true)

            textEditor.addEventListener 'modeChanged', (event) =>
                $scope.$evalAsync () =>
                    $scope.mode = event.detail
                    $scope.setEditMode(true)
                    localStorage.setItem('editor-mode', $scope.mode)

            textEditor.addEventListener 'focusChanged', (event) =>
                if event.detail
                    $scope.$evalAsync () => $scope.setEditMode(true)

            textEditor.addEventListener 'changed', (event) =>
                if $scope.mode == 'html'
                    $scope.html = event.detail
                else
                    $scope.markdown = event.detail

                throttleChange()


            $el.find('.editor-wrapper')[0].appendChild(textEditor)

        setHtmlEditor = (markdown) ->
            wysiwygService.refreshAttachmentURLFromMarkdown(markdown).then (markdown) =>
                textEditor.markdown = markdown

        $scope.setEditMode = (editMode) ->
            $scope.editMode = editMode

            if editMode
                textEditor.mode = $scope.mode
            else
                textEditor.mode = 'html'

        $scope.save = (e) ->
            e.preventDefault() if e

            setHtmlEditor($scope.markdown)

            return if $scope.required && !$scope.markdown.length

            $scope.saving  = true
            $scope.outdated = false

            $scope.onSave({text: $scope.markdown, cb: saveEnd})

            linksEvents()

            return

        $scope.cancel = (e) ->
            e.preventDefault() if e

            if !isEditOnly
                $scope.setEditMode(false)

            if notPersist
                clean()
            else
                $scope.markdown = $scope.content
                setHtmlEditor($scope.content || '')

            discardLocalStorage()
            $scope.outdated = false

            $scope.onCancel()

            linksEvents()

            return

        clean = () ->
            $scope.markdown = ''
            setHtmlEditor('')

        saveEnd = () ->
            $scope.saving  = false

            if !isEditOnly
                $scope.setEditMode(false)

            if notPersist
                clean()

            discardLocalStorage()

            analytics.trackEvent('develop', 'save wysiwyg', $scope.mode, 1)

        isOutdated = () ->
            store = $storage.get($scope.storageKey)

            if store && store.version && store.version != $scope.version
                return true

            return false

        isDraft = () ->
            store = $storage.get($scope.storageKey)

            if store
                return true

            return false

        getCurrentContent = () ->
            store = $storage.get($scope.storageKey)

            if store
                return store.text

            return $scope.content

        discardLocalStorage = () ->
            $storage.remove($scope.storageKey)

        $scope.cancelWithConfirmation = () ->
            if $scope.content == $scope.markdown
                $scope.cancel()
                if document.activeElement.blur
                    document.activeElement.blur()
                document.body.click()

                return null

            title = $translate.instant("COMMON.CONFIRM_CLOSE_EDIT_MODE_TITLE")
            message = $translate.instant("COMMON.CONFIRM_CLOSE_EDIT_MODE_MESSAGE")

            $confirm.ask(title, null, message).then (askResponse) ->
                $scope.cancel()
                askResponse.finish()

        updateMarkdownWithCurrentHtml = () ->
            $scope.markdown = wysiwygService.getMarkdown($scope.html)

        localSave = (markdown) ->
            if $scope.storageKey
                store = {}
                store.version = $scope.version || 0
                store.text = markdown
                $storage.set($scope.storageKey, store)

        change = () ->
            if !$scope.editMode
                return

            if $scope.mode == 'html'
                updateMarkdownWithCurrentHtml()

            localSave($scope.markdown)

            $scope.onChange({markdown: $scope.markdown})

        throttleChange = _.throttle(change, 200)

    return {
        templateUrl: "common/components/wysiwyg-toolbar.html",
        scope: {
            htmlReadMode: '<'
            editonly: '<',
            project: '<',
            placeholder: '<',
            version: '<',
            storageKey: '<',
            content: '<',
            onCancel: '&',
            onSave: '&',
            onUploadFile: '<',
            onChange: '&'
        },
        link: link
    }

angular.module("taigaComponents").directive("tgWysiwyg", [
    "$translate",
    "$tgConfirm",
    "$tgStorage",
    "tgWysiwygService",
    "animationFrame",
    "tgLoader",
    "$tgAnalytics",
    "$location",
    "tgAttachmentsFullService",
    Wysiwyg
])
