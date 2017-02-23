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
        // select the first paragraph
        var range = document.createRange();
        range.selectNode(arguments[0].firstChild);

        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    }, elm.getWebElement());

    browser.actions().mouseUp().perform(); // trigger medium events
}

function resetSelection() {
    browser.executeScript(function () {
        var sel = window.getSelection();
        sel.removeAllRanges();
    });

    browser.actions().mouseUp().perform(); // trigger medium events
}

function getMarkdownText(elm) {
    var markdownTextarea = getMarkdownTextarea(elm);

    return markdownTextarea.getAttribute("value");
}

function getMarkdownTextarea(elm) {
    return elm.$('.e2e-markdown-textarea');}


function htmlMode() {
    $('.e2e-html-mode').click();
}

function markdownMode() {
    $('.e2e-markdown-mode').click();
}

function saveEdition() {
    $('.e2e-save-editor').click();
}

function cancelEdition(elm) {
    $('.e2e-cancel-editor').click();

    return browser.wait(async () => {
        return !!await elm.$$('.read-mode').count();
    }, 3000);
}

async function edit(elm, elmWrapper, text = null) {
    await browser.wait(EC.elementToBeClickable(elm), 10000);

    elm.click();

    browser.sleep(200);

    browser.executeScript(function () {
        if(arguments[0].firstChild) {
            var range = document.createRange();
            range.setStart(arguments[0].firstChild, 0);
            range.setEnd(arguments[0].lastChild, 0);

            var sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }, elm.getWebElement());

    if (text !== null) {
        await cleanWysiwyg(elm, elmWrapper);

        return elm.sendKeys(text);
    }
}

async function cleanWysiwyg(elm, elmWrapper) {
    let isHtmlMode = await elm.isDisplayed();

    if (isHtmlMode) {
        let isPresent = await $('.e2e-markdown-mode').isPresent();

        markdownMode();
    }
     var markdownTextarea = getMarkdownTextarea(elmWrapper);

    await utils.common.clear(markdownTextarea);

    return htmlMode();
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

        markdownMode();

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('**test**');

        htmlMode();

        saveEdition();

        let newCommentsCounter = await historyHelper.countComments();
        expect(newCommentsCounter).to.be.equal(commentsCounter+1);
    });

    it('convert to html', async () => {
        let commentsCounter = await historyHelper.countComments();

        await edit(editor, editorWrapper, '');

        markdownMode();

        let markdownTextarea = getMarkdownTextarea(editorWrapper);

        await markdownTextarea.sendKeys('_test2_');

        htmlMode();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><em>test2</em></p>\n');

        saveEdition();

        let newCommentsCounter = await historyHelper.countComments();
        expect(newCommentsCounter).to.be.equal(commentsCounter+1);
    });

    it('code block', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys("var test = 2;");

        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-button-last').click();

        $('.code-language-selector').click();
        $('.code-language-search input').sendKeys('javascript');
        $('.code-language-search li').click();

        saveEdition();

        let lastComment = historyHelper.getComments().last();

        let hasHightlighter = !!await lastComment.$$('.token').count();

        expect(hasHightlighter).to.be.true;
    });

    it('confirm exit when there is changes', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
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

        editor.sendKeys('@use');

        $$('.medium-mention li').get(2).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><a href="/profile/user8">@user8</a>&nbsp;</p>');

        markdownMode();

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('[@user8](/profile/user8)');

        htmlMode();

        await cancelEdition(editorWrapper);
    });

    it('emojis', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys(':smil');

        $$('.medium-mention li').get(2).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.include('1f604.png');

        markdownMode();

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal(':smile:');

        htmlMode();

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

        saveEdition();

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
};

shared.wysiwygTesting = function(parentSelector) {
    var editor;
    var editorWrapper;

    beforeEach(async () => {
        let isReadMode = !!await editorWrapper.$$('.read-mode').count();

        if (isReadMode) {
            editor.click();
        }

        await cleanWysiwyg(editor, editorWrapper);

        markdownMode();

        var markdownTextarea = getMarkdownTextarea(editorWrapper);

        browser.wait(EC.elementToBeClickable(markdownTextarea), 10000);

        await markdownTextarea.sendKeys('test');

        htmlMode();

        saveEdition();

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

        expect(html).to.be.eql('<p><b>test</b></p>');

        saveEdition();

        await edit(editor, editorWrapper);

        markdownMode();

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('**test**');
    });

    it('convert to html', async () => {
        await edit(editor, editorWrapper, '');

        markdownMode();

        let markdownTextarea = getMarkdownTextarea(editorWrapper);

        await markdownTextarea.sendKeys('_test2_');

        htmlMode();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><em>test2</em></p>\n');
    });

    it('code block', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys("var test = 2;");

        selectEditorFirstChild(editor);

        $('.medium-editor-toolbar-active .medium-editor-button-last').click();

        $('.code-language-selector').click();
        $('.code-language-search input').sendKeys('javascript');
        $('.code-language-search li').click();

        saveEdition();

        let hasHightlighter = !!await editor.$$('.token').count();

        expect(hasHightlighter).to.be.true;
    });

    it('save with confirmconfirm exit when there is changes', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys('text text text');
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

        editor.sendKeys('@use');

        $$('.medium-mention li').get(2).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.be.eql('<p><a href="/profile/user8">@user8</a>&nbsp;</p>');

        markdownMode();

        let markdown = await getMarkdownText(editorWrapper);

        expect(markdown).to.be.equal('[@user8](/profile/user8)');

        htmlMode();
    });

    it('emojis', async () => {
        await edit(editor, editorWrapper, '');

        editor.sendKeys(':smil');

        $$('.medium-mention li').get(2).click();

        let html = await editor.getAttribute("innerHTML");

        expect(html).to.include('1f604.png');

        markdownMode();

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
};
