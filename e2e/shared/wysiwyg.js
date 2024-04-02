/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

var detailHelper = require('../helpers').detail;
var historyHelper = detailHelper.history();

var utils = require('../utils');
var EC = protractor.ExpectedConditions;

chai.use(chaiAsPromised);
var expect = chai.expect;

var shared = module.exports;

function selectEditorFirstChild(elm) {
    browser.executeScript(function () {
        var range = document.createRange();

        range.setStart(arguments[0].firstChild.firstChild, 0);
        range.setEnd(arguments[0].firstChild.firstChild, arguments[0].firstChild.innerText.length);

        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    }, elm.getWebElement());

    browser.actions().mouseUp().perform(); //trigger medium events
}

function resetSelection() {
    browser.executeScript(function () {
        var sel = window.getSelection();
        sel.removeAllRanges();
    });

    browser.actions().mouseUp().perform(); //trigger medium events
}

function getMarkdownText(elm) {
    var markdownTextarea = getMarkdownTextarea(elm);

    return markdownTextarea.getAttribute("value");
}

function getMarkdownTextarea(elm) {
    return elm.$('.e2e-markdown-textarea');}


function htmlMode(elm) {
    elm.$('.e2e-html-mode').click();

    return utils.common.waitElementPresent($('.e2e-markdown-mode'));
}

function markdownMode(elm) {
    elm.$('.e2e-markdown-mode').click();

    return utils.common.waitElementPresent($('.e2e-html-mode'));
}

function saveEdition(elm) {
    return elm.$('.e2e-save-editor').click();
}

function cancelEdition(elm) {
    elm.$('.e2e-cancel-editor').click();

    return browser.wait(async () => {
        return !!await elm.$$('.read-mode').count();
    }, 3000);
}

function closeMention() {
    return utils.common.waitElementNotPresent($('.medium-mention'));
}

function preventThrottle() {
    return browser.sleep(250);
}

function getSnippeLightbox(parent) {
    let el = parent.$('tg-wysiwyg-code-lightbox');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        select: function(lan) {
            return el.$('select').sendKeys('javascript');
        },
        save: function() {
            return el.$('button').click();
        }
    };

    return obj;
};

async function edit(elm, elmWrapper, text = null) {
    await browser.wait(EC.elementToBeClickable(elm), 10000);

    elm.click();

    await browser.sleep(2000);

    if (text !== null) {
        await cleanWysiwyg(elm, elmWrapper);

        return elm.sendKeys(text);
    }
};

async function cleanWysiwyg(elm, elmWrapper) {
    await browser.executeScript(function () {
        if(arguments[0].firstChild) {
            var range = document.createRange();
            range.setStart(arguments[0].firstChild, 0);
            range.setEnd(arguments[0].lastChild, 0);

            var sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }, elm.getWebElement());

    return elm.sendKeys(protractor.Key.BACK_SPACE);
}

shared.wysiwygTestingComments = function(parentSelector, section) {
    var editor;
    var editorWrapper;

    beforeEach(() => {
        let parent = $(parentSelector);
        editor = parent.$('.medium');
        editorWrapper = parent.$('tg-wysiwyg');
    });

    it('bold, test normal behavior and check markdown', async () => {
        let commentsCounter = await historyHelper.countComments();

        await edit(editor, editorWrapper, "test");
        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-action-bold').click();

        resetSelection();

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('**test**');

        await htmlMode(editorWrapper);

        await saveEdition(editorWrapper);

        let newCommentsCounter = await historyHelper.countComments();
        expect(newCommentsCounter).to.be.equal(commentsCounter+1);
    });

    it('convert to html', async () => {
        let commentsCounter = await historyHelper.countComments();

        await edit(editor, editorWrapper, '');

        markdownMode(editorWrapper);

        let markdownTextarea = getMarkdownTextarea(editorWrapper);

        await markdownTextarea.sendKeys('_test2_');

        await htmlMode(editorWrapper);

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><em>test2</em></p>\n');

        await saveEdition(editorWrapper);

        let newCommentsCounter = await historyHelper.countComments();
        expect(newCommentsCounter).to.be.equal(commentsCounter+1);
    });

    it('confirm exit when there is changes', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
        await preventThrottle();
        editor.sendKeys(protractor.Key.ESCAPE);

        await utils.lightbox.confirm.ok();

        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        expect(isReadMode).to.be.true;

        let html = await editor.getText();

        expect(html).not.to.be.eql('text text text');
    });

    it('keep changes on reload', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
        await preventThrottle();
        editor.sendKeys(protractor.Key.ESCAPE);

        browser.sleep(400);
        browser.refresh();

        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        expect(isReadMode).to.be.false;

        let html = await editor.getText();

        expect(html).to.be.eql('text text text');

        await cancelEdition(editorWrapper);
    });

    it('mention user', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('@user8');

        $$('.medium-mention li').get(0).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><a href="/profile/user8">@user8</a>&nbsp;</p>');

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('[@user8](/profile/user8)');

        await htmlMode(editorWrapper);

        await cancelEdition(editorWrapper);
    });

    it('emojis', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys(':smil');

        $$('.medium-mention li').get(2).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.include('1f604.png');

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal(':smile:');

        await htmlMode(editorWrapper);

        await cancelEdition(editorWrapper);
    });

    it('cancel', async () => {
        let prevHtml = await editor.getAttribute("innerHTML");

        await edit(editor, editorWrapper, 'xxx yyy zzz');

        await cancelEdition(editorWrapper);

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.equal(prevHtml);
    });

    it('edit comment', async () => {
        historyHelper.editLastComment();

        let editWrapperLast = historyHelper.getComments().last();
        let editLast = editWrapperLast.$('.medium');

        await edit(editLast, editWrapperLast, "This is the new and updated text");
        await utils.common.takeScreenshot(section, "edit comment");

        await saveEdition(editWrapperLast);

        //Show versions from last comment edited
        historyHelper.showVersionsLastComment();
        await utils.common.takeScreenshot(section, "show comment versions");

        historyHelper.closeVersionsLastComment();
    });

    it('delete last comment', async () => {
        let deletedCommentsCounter = await historyHelper.countDeletedComments();
        await historyHelper.deleteLastComment();

        let newDeletedCommentsCounter = await historyHelper.countDeletedComments();

        expect(newDeletedCommentsCounter).to.be.equal(deletedCommentsCounter+1);

        await utils.common.takeScreenshot(section, 'deleted comment');
    });

    it('restore last comment', async () => {
        let deletedCommentsCounter = await historyHelper.countDeletedComments();

        await historyHelper.restoreLastComment();

        let newDeletedCommentsCounter = await historyHelper.countDeletedComments();

        expect(newDeletedCommentsCounter).to.be.equal(deletedCommentsCounter-1);

        await utils.common.takeScreenshot(section, 'restored comment');
    });

    it('code block', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys("var test = 2;");

        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-button-last').click();

        browser.actions().doubleClick(editor.$('code')).perform();

        let lb = getSnippeLightbox(editorWrapper);

        await lb.waitOpen();

        await lb.select('javascript');
        await lb.save();
        await lb.waitClose();

        let hasHightlighter = !!await editor.$$('.token').count();

        expect(hasHightlighter).to.be.true;

        await saveEdition(editorWrapper);
    });
};

shared.wysiwygTesting = function(parentSelector) {
    var editor;
    var editorWrapper;

    beforeEach(async () => {
        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        if (isReadMode) {
            editor.click();
        }

        let isHtmlMode = await editor.isDisplayed();
        if (!isHtmlMode) {
            await htmlMode(editorWrapper);
        }

        await cleanWysiwyg(editor, editorWrapper);

        markdownMode(editorWrapper);

        var markdownTextarea = getMarkdownTextarea(editorWrapper);

        browser.wait(EC.elementToBeClickable(markdownTextarea), 10000);

        await markdownTextarea.sendKeys('test');

        await htmlMode(editorWrapper);

        await saveEdition(editorWrapper);

        await browser.wait(EC.elementToBeClickable(editor), 10000);
    });

    before(() => {
        let parent = $(parentSelector);
        editor = parent.$('.medium');
        editorWrapper = parent.$('tg-wysiwyg');
    });

    it('bold, test normal behavior and check markdown', async () => {
        await edit(editor, editorWrapper, "test");
        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-action-bold').click();

        resetSelection();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><b>test</b></p>\n');

        await saveEdition(editorWrapper);

        await edit(editor, editorWrapper);

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('**test**');
    });

    it('convert to html', async () => {
        await edit(editor, editorWrapper, '');

        markdownMode(editorWrapper);

        let markdownTextarea = getMarkdownTextarea(editorWrapper);

        await markdownTextarea.sendKeys('_test2_');

        htmlMode(editorWrapper);

       let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><em>test2</em></p>\n');
    });

    it('save with confirmconfirm exit when there is changes', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
        await preventThrottle();
        editor.sendKeys(protractor.Key.ESCAPE);

        await utils.lightbox.confirm.ok();

        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        expect(isReadMode).to.be.true;

        let html = await editor.getText();

        expect(html).not.to.be.eql('text text text');
    });

    it('keep changes on reload', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
        await preventThrottle();
        editor.sendKeys(protractor.Key.ESCAPE);

        browser.sleep(400);
        browser.refresh();

        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        expect(isReadMode).to.be.false;

        let html = await editor.getText();

        expect(html).to.be.eql('text text text');
    });

    it('mention user', async () => {
        await edit(editor, editorWrapper, '');

        await editor.sendKeys('@user5');

        $$('.medium-mention li').get(0).click();

        await closeMention();

        let html = await editor.getAttribute("innerHTML");


        expect(html).to.be.eql('<p><a href="/profile/user5">@user5</a>&nbsp;</p>\n');

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('[@user5](/profile/user5)');

        htmlMode(editorWrapper);
    });

    it('emojis', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys(':smil');

        await $$('.medium-mention li').get(2).click();

        await closeMention();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.include('1f604.png');

        markdownMode(editorWrapper);

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal(':smile:');
    });

    it('cancel', async () => {
       let prevHtml = await editor.getAttribute("innerHTML");

        await edit(editor, editorWrapper, 'xxx yyy zzz');

        await cancelEdition(editorWrapper);

       let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.equal(prevHtml);
    });

    it('code block', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys("var test = 2;");

        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-button-last').click();

        browser.actions().doubleClick(editor.$('code')).perform();

        let lb = getSnippeLightbox(editorWrapper);

        await lb.waitOpen();

        await lb.select('javascript');
        await lb.save();
        await lb.waitClose();

        await saveEdition(editorWrapper);

        let hasHightlighter = !!await editor.$$('.token').count();

        expect(hasHightlighter).to.be.true;
    });
};
