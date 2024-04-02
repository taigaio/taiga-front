/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var MentionExtension = MediumEditor.Extension.extend({
    name: 'mediumMention',
    init: function() {
        this.subscribe('editableKeyup', this.handleKeyup.bind(this));
        this.subscribe('editableKeydown', this.handleKeydown.bind(this));
        this.subscribe('blur', this.cancel.bind(this));
    },
    isEditMode: function() {
        return !this.base.origElements.parentNode.classList.contains('read-mode');
    },
    cancel: function() {
        if (this.isEditMode()) {
            this.hidePanel();
            this.reset();
        }
    },
    handleKeydown: function(e) {
        var code = e.keyCode ? e.keyCode : e.which;

        if (this.mentionPanel && code === MediumEditor.util.keyCode.ENTER) {
            e.preventDefault();
        }
    },
    handleKeyup: function(e) {
        var code = e.keyCode ? e.keyCode : e.which;
        var isSpace = code === MediumEditor.util.keyCode.SPACE;
        var isBackspace = code === MediumEditor.util.keyCode.BACKSPACE;

        if (this.mentionPanel) {
            this.keyDownMentionPanel(e);
        }

        var moveKeys = [37, 38, 39, 40];

        if (moveKeys.indexOf(code) !== -1) {
            return;
        }

        this.selection = this.document.getSelection();

        if (isBackspace && this.selection.focusNode.nodeName.toLowerCase() === 'p') {
            return;
        }

        if (!isSpace && this.selection.rangeCount === 1) {
            var endChar = this.selection.getRangeAt(0).startOffset;
            var textContent = this.selection.focusNode.textContent;

            textContent = textContent.substring(0, endChar);
            this.word = this.getLastWord(textContent);

            if (this.word.length > 1 && ['@', '#', ':'].indexOf(this.word[0]) != -1) {
                this.wrap();
                this.showPanel();

                MediumEditor.selection.select(
                  this.document,
                  this.wordNode.firstChild,
                  this.word.length
                );

                return;
            }
        } else if (isSpace) {
            this.cancelMentionSpace();
        }

        this.hidePanel();
    },
    reset: function() {
        this.wordNode = null;
        this.word = null;
        this.selection = null;
    },
    cancelMentionSpace: function() {
        if (this.wordNode && this.wordNode.nextSibling) {
            var textNode = this.document.createTextNode('');
            textNode.textContent = this.word + '\u00A0';

            this.wordNode.parentNode.replaceChild(textNode, this.wordNode);

            MediumEditor.selection.select(this.document, textNode, this.word.length + 1);
        }

        this.reset();
    },
    wrap: function() {
        var range = this.selection.getRangeAt(0).cloneRange();

        if (range.startContainer.parentNode.nodeName.toLowerCase() === 'a') {
            var parentLink = range.startContainer.parentNode.parentNode;
            var textNode = this.document.createTextNode(range.startContainer.parentNode.innerText);

            parentLink.replaceChild(textNode, range.startContainer.parentNode);

            this.selection.removeAllRanges();

            range = document.createRange();

            range.setStart(textNode, textNode.length);
            range.setEnd(textNode, textNode.length);

            this.selection.addRange(range);
        }

        if (!range.startContainer.parentNode.classList.contains('mention')) {
            this.wordNode = this.document.createElement('span');
            this.wordNode.classList.add('mention');

            range.setStart(range.startContainer, this.selection.getRangeAt(0).startOffset - this.word.length);
            range.surroundContents(this.wordNode);

            this.selection.removeAllRanges();
            this.selection.addRange(range);

            //move cursor to old position
            range.setStart(range.startContainer, range.endOffset);
            range.setStart(range.endContainer, range.endOffset);
            this.selection.removeAllRanges();
            this.selection.addRange(range);
        } else {
            this.wordNode = range.startContainer.parentNode;
        }
    },
    refreshPositionPanel: function() {
        var bound = this.wordNode.getBoundingClientRect();

        this.mentionPanel.style.top = this.window.pageYOffset + bound.bottom + 'px';
        this.mentionPanel.style.left = this.window.pageXOffset + bound.left + 'px';
    },
    selectMention: function(item) {
        if (item.image) {
            var img = document.createElement('img');
            img.src = item.image;

            this.wordNode.parentNode.replaceChild(img, this.wordNode);
            this.wordNode = img;
        } else {
            var link = document.createElement('a');

            link.setAttribute('href', item.url);

            if (item.ref) {
                link.innerText = '#' + item.ref + '-' + item.subject;
            } else {
                link.innerText = '@' + item.username;
            }

            this.wordNode.parentNode.replaceChild(link, this.wordNode);
            this.wordNode = link;
        }

        var textNode = this.document.createTextNode('');
        textNode.textContent = '\u00A0';

        this.wordNode.parentNode.insertBefore(textNode, this.wordNode.nextSibling);
        MediumEditor.selection.select(this.document, textNode, 1);

        var target = this.base.getFocusedElement();

        this.base.events.updateInput(target, {
          target: target,
          currentTarget: target
        });

        this.hidePanel();
        this.reset();
    },
    showPanel: function() {
        if(document.querySelectorAll('.medium-editor-mention-panel').length) {
            this.refreshPositionPanel();
            this.getItems(this.word, this.renderPanel.bind(this));
            return;
        }

        var  el = this.document.createElement('div');
        el.classList.add('medium-editor-mention-panel');
        this.mentionPanel = el;
        this.getEditorOption('elementsContainer').appendChild(el);

        this.refreshPositionPanel();
        this.getItems(this.word, this.renderPanel.bind(this));
    },
    keyDownMentionPanel: function(e) {
        var code = e.keyCode ? e.keyCode : e.which;
        var active = this.mentionPanel.querySelector('.active');

        this.wordNode = document.querySelector('span.mention');

        if(!active) {
            return;
        }

        if (code === MediumEditor.util.keyCode.ENTER) {
            e.preventDefault();
            e.stopPropagation();

            var event = document.createEvent('HTMLEvents');
            event.initEvent('mousedown', true, false);

            active.dispatchEvent(event);

            return;
        }

        active.classList.remove('active');

        if (code === 38) {
            if(active.previousSibling) {
                active.previousSibling.classList.add('active');
            } else {
                active.parentNode.lastChild.classList.add('active');
            }
        } else if (code === 40) {
            if(active.nextSibling) {
                active.nextSibling.classList.add('active');
            } else {
                active.parentNode.firstChild.classList.add('active');
            }
        }
    },
    renderPanel: function(items) {
        this.mentionPanel.innerHTML = '';

        if (!items.length) return;

        var ul = this.document.createElement('ul');

        ul.classList.add('medium-mention');

        items.forEach(function(it) {
            var li = this.document.createElement('li');

            if (it.image) {
                var img = this.document.createElement('img');

                img.src = it.image;
                li.appendChild(img);

                var textNode = document.createTextNode('');
                textNode.textContent = ' ' + it.name;

                li.appendChild(textNode);

            } else if (it.ref) {
                li.innerText = '#' + it.ref + ' - ' + it.subject;
            } else {
                if (it.full_name) {
                    li.innerText = '@' + it.full_name + ' (' + it.username + ')';
                } else {
                    li.innerText = '@' + it.username;
                }
            }

            li.addEventListener('mousedown', this.selectMention.bind(this, it));

            ul.appendChild(li);
        }.bind(this));

        ul.firstChild.classList.add('active');

        this.mentionPanel.appendChild(ul);
    },
    hidePanel: function() {
        if (this.mentionPanel) {
            this.mentionPanel.parentNode.removeChild(this.mentionPanel);
            this.mentionPanel = null;
        }
    },
    getLastWord: function(text) {
        var n = text.split(' ');
        return n[n.length - 1].trim();
    }
});
