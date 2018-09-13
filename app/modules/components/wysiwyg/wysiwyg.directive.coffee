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
# File: components/wysiwyg/wysiwyg.directive.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

Medium = ($translate, $confirm, $storage, wysiwygService, animationFrame, tgLoader, wysiwygCodeHightlighterService, wysiwygMentionService, analytics, $location) ->
    removeSelections = () ->
        if window.getSelection
            if window.getSelection().empty
                window.getSelection().empty();
        else if window.getSelection().removeAllRanges
            window.getSelection().removeAllRanges()

        else if document.selection
            document.selection.empty()

    getRangeCodeBlock = (range) ->
        return $(range.endContainer).parentsUntil('.editor', 'code')

    isCodeBlockSelected = (range) ->
        return !!getRangeCodeBlock(range).length

    removeCodeBlockAndHightlight = (selection, mediumInstance) ->
        if $(selection).is('code')
            code = selection
        else
            code = $(selection).closest('code')[0]

        pre = code.parentNode

        p = document.createElement('p')
        p.innerText = code.innerText

        pre.parentNode.replaceChild(p, pre)
        mediumInstance.checkContentChanged(mediumInstance.elements[0])

    addCodeBlockAndHightlight = (range, mediumInstance) ->
        pre = document.createElement('pre')
        code = document.createElement('code')

        if !range.startContainer.parentNode.nextSibling
            $('<br/>').insertAfter(range.startContainer.parentNode)

        start = range.endContainer.parentNode.nextSibling

        extract = range.extractContents()

        code.appendChild(extract)

        pre.appendChild(code)

        start.parentNode.insertBefore(pre, start)

        refreshCodeBlocks(mediumInstance)
        mediumInstance.checkContentChanged(mediumInstance.elements[0])

    refreshCodeBlocks = (mediumInstance) ->
        return if !mediumInstance

        # clean empty <p> content editable adds it when range.extractContents has been execute it
        for mainChildren in mediumInstance.elements[0].children
            if mainChildren && mainChildren.tagName.toLowerCase() == 'p' && !mainChildren.innerHTML.trim().length
                mainChildren.parentNode.removeChild(mainChildren)

        preList = mediumInstance.elements[0].querySelectorAll('pre')

        for pre in preList
            # prevent edit a pre
            pre.setAttribute('contenteditable', false)

            pre.setAttribute('title', $translate.instant("COMMON.WYSIWYG.DB_CLICK"))

            # prevent text selection in firefox
            pre.addEventListener 'mousedown', (e) -> e.preventDefault()

            if pre.nextElementSibling && pre.nextElementSibling.nodeName.toLowerCase() == 'p' && !pre.nextElementSibling.children.length
                pre.nextElementSibling.appendChild(document.createElement('br'))

            # add p after every pre
            else if !pre.nextElementSibling || ['p', 'ul', 'h1', 'h2', 'h3'].indexOf(pre.nextElementSibling.nodeName.toLowerCase()) == -1
                p = document.createElement('p')
                p.appendChild(document.createElement('br'))

                pre.parentNode.insertBefore(p, pre.nextSibling)

    AlignRightButton = MediumEditor.extensions.button.extend({
        name: 'rtl',
        init: () ->
            option = _.find this.base.options.toolbar.buttons, (it) ->
                it.name == 'rtl'

            this.button = this.document.createElement('button')
            this.button.classList.add('medium-editor-action')
            this.button.innerHTML = option.contentDefault || '<b>RTL</b>'
            this.button.title = 'RTL'
            this.on(this.button, 'click', this.handleClick.bind(this))

        getButton: () ->
            return this.button
        handleClick: (event) ->
            range = MediumEditor.selection.getSelectionRange(document)
            if range.commonAncestorContainer.parentNode.style.textAlign == 'right'
                document.execCommand('justifyLeft', false)
            else
                document.execCommand('justifyRight', false)

    })

    getIcon = (icon) ->
        return """<svg class="icon icon-#{icon}">
            <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="##{icon}"></use>
        </svg>"""

    # MediumEditor extension to add <code>
    CodeButton = MediumEditor.extensions.button.extend({
        name: 'code',
        init: () ->
            option = _.find this.base.options.toolbar.buttons, (it) ->
                it.name == 'code'

            this.button = this.document.createElement('button')
            this.button.classList.add('medium-editor-action')
            this.button.innerHTML = option.contentDefault || '<b>Code</b>'
            this.button.title = 'Code'
            this.on(this.button, 'click', this.handleClick.bind(this))

        getButton: () ->
            return this.button

        tagNames: ['code']

        handleClick: (event) ->
            range = MediumEditor.selection.getSelectionRange(self.document)

            if isCodeBlockSelected(range, this.base)
                removeCodeBlockAndHightlight(range.endContainer, this.base)
            else
                addCodeBlockAndHightlight(range, this.base)
                removeSelections()

            toolbar = this.base.getExtensionByName('toolbar')

            if toolbar
                toolbar.hideToolbar()

    })

    CustomPasteHandler = MediumEditor.extensions.paste.extend({
        doPaste: (pastedHTML, pastedPlain, editable) ->
            html = MediumEditor.util.htmlEntities(pastedPlain);

            MediumEditor.util.insertHTMLCommand(this.document, html);
    })

    # bug
    # <pre><code></code></pre> the enter key press doesn't work
    oldIsBlockContainer = MediumEditor.util.isBlockContainer

    MediumEditor.util.isBlockContainer = (element) ->
        if !element
            return oldIsBlockContainer(element)

        if element.tagName
            tagName = element.tagName
        else
            tagName = element.parentNode.tagName

        if tagName.toLowerCase() == 'code'
            return true

        return oldIsBlockContainer(element)

    link = ($scope, $el, $attrs) ->
        mediumInstance = null
        editorMedium = $el.find('.medium')
        editorMarkdown = $el.find('.markdown')
        codeBlockSelected = null

        isEditOnly = !!$attrs.$attr.editonly
        notPersist = !!$attrs.$attr.notPersist

        $scope.required = !!$attrs.$attr.required
        $scope.editMode = isEditOnly || false
        $scope.mode = $storage.get('editor-mode', 'html')
        $scope.markdown = ''
        $scope.codeEditorVisible = false
        $scope.codeLans = []

        wysiwygCodeHightlighterService.getLanguages().then (codeLans) ->
            $scope.codeLans = codeLans

        setEditMode = (editMode) ->
            $scope.editMode = editMode

        setHtmlMedium = (markdown) ->
            html = wysiwygService.getHTML(markdown)
            editorMedium.html(html)
            wysiwygCodeHightlighterService.addHightlighter(mediumInstance.elements[0])

            if $scope.editMode
                refreshCodeBlocks(mediumInstance)

        $scope.saveSnippet = (lan, code) ->
            $scope.codeEditorVisible = false
            codeBlockSelected.innerText = code
            codePre = codeBlockSelected.parentNode

            if lan == 'remove-formating'
                    codeBlockSelected.className = ''
                    codePre.className = ''

                    removeCodeBlockAndHightlight(codeBlockSelected, mediumInstance)
            else if _.trim(code).length
                if lan
                    codeBlockSelected.className = 'language-' + lan
                    codePre.className = 'language-' + lan
                else
                    codeBlockSelected.className = ''
                    codePre.className = ''

                wysiwygCodeHightlighterService.hightlightCode(codeBlockSelected)
                mediumInstance.checkContentChanged(mediumInstance.elements[0])
            else
                codeBlockSelected.parentNode.parentNode.removeChild(codeBlockSelected.parentNode)
                mediumInstance.checkContentChanged(mediumInstance.elements[0])

            throttleChange()

            return null

        $scope.setMode = (mode) ->
            $storage.set('editor-mode', mode)

            if mode == 'markdown'
                updateMarkdownWithCurrentHtml()
            else
                setHtmlMedium($scope.markdown)

            $scope.mode = mode
            mediumInstance.trigger('editableBlur', {}, editorMedium[0])

        $scope.save = (e) ->
            e.preventDefault() if e

            if $scope.mode == 'html'
                updateMarkdownWithCurrentHtml()

            setHtmlMedium($scope.markdown)

            return if $scope.required && !$scope.markdown.length

            $scope.saving  = true
            $scope.outdated = false

            $scope.onSave({text: $scope.markdown, cb: saveEnd})

            return

        $scope.cancel = (e) ->
            e.preventDefault() if e

            if !isEditOnly
                setEditMode(false)

            if notPersist
                clean()
            else if $scope.mode == 'html'
                setHtmlMedium($scope.content || null)

            $scope.markdown = $scope.content

            discardLocalStorage()
            mediumInstance.trigger('blur', {}, editorMedium[0])
            $scope.outdated = false
            refreshCodeBlocks(mediumInstance)

            $scope.onCancel()

            return

        clean = () ->
            $scope.markdown = ''
            editorMedium.html('')

        saveEnd = () ->
            $scope.saving  = false

            if !isEditOnly
                setEditMode(false)

            if notPersist
                clean()

            discardLocalStorage()
            mediumInstance.trigger('blur', {}, editorMedium[0])

            analytics.trackEvent('develop', 'save wysiwyg', $scope.mode, 1)

        uploadEnd = (name, url) ->
            if taiga.isImage(name)
                mediumInstance.pasteHTML("<img src='" + url + "' /><br/>")
            else
                name = $('<div/>').text(name).html()
                mediumInstance.pasteHTML("<a target='_blank' href='" + url + "'>" + name + "</a><br/>")

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

                document.activeElement.blur()
                document.body.click()

                return null

            title = $translate.instant("COMMON.CONFIRM_CLOSE_EDIT_MODE_TITLE")
            message = $translate.instant("COMMON.CONFIRM_CLOSE_EDIT_MODE_MESSAGE")

            $confirm.ask(title, null, message).then (askResponse) ->
                $scope.cancel()
                askResponse.finish()

        # firefox adds br instead of new lines inside <code>, taiga must replace the br by \n before sending to the server
        replaceCodeBrToNl = () ->
            html = $('<div></div>').html(editorMedium.html())
            html.find('code br').replaceWith('\n')

            return html.html()

        updateMarkdownWithCurrentHtml = () ->
            html = replaceCodeBrToNl()
            $scope.markdown = wysiwygService.getMarkdown(html)

        localSave = (markdown) ->
            if $scope.storageKey
                store = {}
                store.version = $scope.version || 0
                store.text = markdown
                $storage.set($scope.storageKey, store)

        change = () ->
            if $scope.mode == 'html'
                updateMarkdownWithCurrentHtml()

            localSave($scope.markdown)

            $scope.onChange({markdown: $scope.markdown})

        throttleChange = _.throttle(change, 200)

        create = (text, editMode=false) ->
            if text.length
                html = wysiwygService.getHTML(text)
                editorMedium.html(html)

            mediumInstance = new MediumEditor(editorMedium[0], {
                imageDragging: false,
                placeholder: {
                    text: $scope.placeholder
                },
                toolbar: {
                    buttons: [
                        {
                            name: 'bold',
                            contentDefault: getIcon('editor-bold')
                        },
                        {
                            name: 'italic',
                            contentDefault: getIcon('editor-italic')
                        },
                        {
                            name: 'strikethrough',
                            contentDefault: getIcon('editor-cross-out')
                        },
                        {
                            name: 'anchor',
                            contentDefault: getIcon('editor-link')
                        },
                        {
                            name: 'image',
                            contentDefault: getIcon('editor-image')
                        },
                        {
                            name: 'orderedlist',
                            contentDefault: getIcon('editor-list-n')
                        },
                        {
                            name: 'unorderedlist',
                            contentDefault: getIcon('editor-list-o')
                        },
                        {
                            name: 'h1',
                            contentDefault: getIcon('editor-h1')
                        },
                        {
                            name: 'h2',
                            contentDefault: getIcon('editor-h2')
                        },
                        {
                            name: 'h3',
                            contentDefault: getIcon('editor-h3')
                        },
                        {
                            name: 'quote',
                            contentDefault: getIcon('editor-quote')
                        },
                        {
                            name: 'removeFormat',
                            contentDefault: getIcon('editor-no-format')
                        },
                        {
                            name: 'rtl',
                            contentDefault: getIcon('editor-rtl')
                        },
                        {
                            name: 'code',
                            contentDefault: getIcon('editor-code')
                        }
                    ]
                },
                extensions: {
                    paste: new CustomPasteHandler(),
                    code: new CodeButton(),
                    autolist: new AutoList(),
                    alignright: new AlignRightButton(),
                    mediumMention: new MentionExtension({
                        getItems: (mention, mentionCb) ->
                            wysiwygMentionService.search(mention).then(mentionCb)
                    })
                }
            })

            $scope.changeMarkdown = throttleChange

            mediumInstance.subscribe 'editableInput', (e) ->
                $scope.$applyAsync(throttleChange)

            mediumInstance.subscribe "editableClick", (e) ->
                r = new RegExp('^(?:[a-z]+:)?//', 'i')

                if e.target.href 
                    if r.test(e.target.getAttribute('href')) || e.target.getAttribute('target') == '_blank'
                        e.stopPropagation()
                        window.open(e.target.href)                                                 
                    else 
                        $location.url(e.target.href)

            mediumInstance.subscribe 'editableDrop', (event) ->
                $scope.onUploadFile({files: event.dataTransfer.files, cb: uploadEnd})

            mediumInstance.subscribe 'editableKeydown', (e) ->
                code = if e.keyCode then e.keyCode else e.which

                mention = $('.medium-mention')

                if (code == 40 || code == 38) && mention.length
                    e.stopPropagation()
                    e.preventDefault()

                    return

                if $scope.editMode && code == 27
                    e.stopPropagation()
                    $scope.$applyAsync($scope.cancelWithConfirmation)
                else if code == 27
                    editorMedium.blur()

            setEditMode(editMode)

            $scope.$applyAsync () ->
                wysiwygCodeHightlighterService.addHightlighter(mediumInstance.elements[0])
                refreshCodeBlocks(mediumInstance)

        $(editorMedium[0]).on 'mousedown', (e) -> 
            if e.target.href
                e.preventDefault()
                e.stopPropagation()
            else
                $scope.$applyAsync () ->
                    if !$scope.editMode
                        setEditMode(true)
                        refreshCodeBlocks(mediumInstance)                   

        $(editorMedium[0]).on 'dblclick', 'pre', (e) ->
            $scope.$applyAsync () ->
                $scope.codeEditorVisible = true

                codeBlockSelected = e.currentTarget.querySelector('code')

                $scope.currentCodeLanguage = wysiwygCodeHightlighterService.getLanguageInClassList(codeBlockSelected.classList)
                $scope.code = codeBlockSelected.innerText

        unwatch = $scope.$watch 'content', (content) ->
            if !_.isUndefined(content)
                $scope.outdated = isOutdated()

                if !mediumInstance && isDraft()
                    setEditMode(true)

                if ($scope.markdown.length || content.length) && $scope.markdown == content
                    return

                content = getCurrentContent()

                $scope.markdown = content

                if mediumInstance
                    mediumInstance.destroy()

                if tgLoader.open()
                    unwatchLoader = tgLoader.onEnd () ->
                        create(content, $scope.editMode)
                        unwatchLoader()
                else
                    create(content, $scope.editMode)

                unwatch()

        $scope.$on "$destroy", () ->
            if mediumInstance
                $(editorMedium[0]).off() if editorMedium.length
                mediumInstance.destroy()

    return {
        templateUrl: "common/components/wysiwyg-toolbar.html",
        scope: {
            placeholder: '@',
            version: '<',
            storageKey: '<',
            content: '<',
            onCancel: '&',
            onSave: '&',
            onUploadFile: '&',
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
    "tgWysiwygCodeHightlighterService",
    "tgWysiwygMentionService",
    "$tgAnalytics",
    "$location",
    Medium
])
