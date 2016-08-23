var utils = require('../utils');
var sharedDetail = require('../shared/detail');
var wikiHelper = require('../helpers').wiki;
var sharedWysiwyg = require('../shared/wysiwyg').wysiwygTesting;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('wiki', function() {
    var currentWiki = {};

    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/wiki/home');
        await utils.common.waitLoader();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("wiki", "empty");
    });

    it('add link', async function(){
        let linkText = "Test link" + new Date().getTime();
        await wikiHelper.links().addLink(linkText);

        let timestamp = new Date().getTime();
        currentWiki.slug = "test-link" + timestamp;

        linkText = "Test link" + timestamp;
        currentWiki.link = await wikiHelper.links().addLink(linkText);
    });

    it('follow last link', async function() {
        let lastLink = wikiHelper.links().get().last();

        browser
           .actions()
           .mouseMove(lastLink)
           .click()
           .perform();

        await utils.common.waitLoader();
        await utils.common.takeScreenshot("wiki", "new-link-created-with-empty-wiki-page");

        let url = await browser.getCurrentUrl();

        expect(url).to.be.equal(browser.params.glob.host + 'project/project-0/wiki/' + currentWiki.slug);
    });

    utils.common.browserSkip('internet explorer', "drag & drop links", async function() {
        let nameOld = await wikiHelper.links().getNameOf(0);

        await wikiHelper.dragAndDropLinks(0, 1);

        let nameNew = await wikiHelper.links().getNameOf(0);

        expect(nameNew).to.be.equal(nameOld);

    });

    it('remove link', async function() {
        wikiHelper.links().deleteLink(currentWiki.link);
        await utils.common.takeScreenshot("wiki", "deleting-the-created-link");
    });

    describe('wiki editor', sharedWysiwyg.bind(this));

    it('confirm close with ESC in lightbox', async function() {
        wikiHelper.editor().enabledEditionMode();

        browser.actions().sendKeys(protractor.Key.ESCAPE).perform();

        await utils.lightbox.confirm.cancel();

        let descriptionVisibility = await $('.view-wiki-content').isDisplayed();

        expect(descriptionVisibility).to.be.false;

        wikiHelper.editor().focus();

        browser.actions().sendKeys(protractor.Key.ESCAPE).perform();

        await utils.lightbox.confirm.ok();

        descriptionVisibility = await $('.view-wiki-content').isDisplayed();

        expect(descriptionVisibility).to.be.true;
    });

    it('attachments', sharedDetail.attachmentTesting);

    it('delete', async function() {
        await wikiHelper.editor().delete();

        expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'project/project-0/wiki/home');
    });

    it('Custom keyboard actions', async function(){
        wikiHelper.editor().enabledEditionMode();

        wikiHelper.editor().setText("- aa");
        browser.actions().sendKeys(protractor.Key.ENTER).perform();
        let text = await wikiHelper.editor().getText();
        expect(text).to.be.equal("- aa\n- ");

        wikiHelper.editor().setText("- ");
        browser.actions().sendKeys(protractor.Key.ENTER).perform();
        text = await wikiHelper.editor().getText();
        expect(text).to.be.equal("\n");

        wikiHelper.editor().setText("- bbcc");
        browser.actions().sendKeys(protractor.Key.ARROW_LEFT).sendKeys(protractor.Key.ARROW_LEFT).sendKeys(protractor.Key.ENTER).perform();
        text = await wikiHelper.editor().getText();
        expect(text).to.be.equal("- bb\n- cc");

        wikiHelper.editor().setText("- aa");
        browser.actions().sendKeys(protractor.Key.HOME).sendKeys(protractor.Key.ENTER).perform();
        text = await wikiHelper.editor().getText();
        expect(text).to.be.equal("\n- aa");
    });
});
