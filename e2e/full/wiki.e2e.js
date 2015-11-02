var utils = require('../utils');
var wikiHelper = require('../helpers').wiki;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('wiki', function() {
    let currentWiki = {};

    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/wiki/home');
        await utils.common.waitLoader();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("wiki", "empty");
    });

    it('add link', async function(){
        let timestamp = new Date().getTime();
        currentWiki.slug = "test-link" + timestamp;

        let linkText = "Test link" + timestamp;
        currentWiki.link = await wikiHelper.links().addLink(linkText);
    });

    it('follow last link', async function() {
        // the click event is not on the <a> :(
        let lastLink = wikiHelper.links().get().last().$('.link-title');
        browser
           .actions()
           .mouseMove(lastLink)
           .click()
           .perform();

        await utils.common.waitLoader();
        await utils.common.takeScreenshot("wiki", "new-link-created-with-empty-wiki-page");

        expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'project/project-0/wiki/' + currentWiki.slug);
    });

    it('remove link', async function() {
        wikiHelper.links().deleteLink(currentWiki.link);
        await utils.common.takeScreenshot("wiki", "deleting-the-created-link");
    });

    it('edition', async function() {
        let timesEdited = wikiHelper.editor().getTimesEdited();
        let lastEditionDatetime = wikiHelper.editor().getLastEditionDateTime();
        wikiHelper.editor().enabledEditionMode();
        let settingText = "This is the new text" + new Date().getTime();
        wikiHelper.editor().setText(settingText);

        //preview
        wikiHelper.editor().preview();
        await utils.common.takeScreenshot("wiki", "home-edition-preview");

        //save
        wikiHelper.editor().save();
        let newHtml = await wikiHelper.editor().getInnerHtml();
        let newTimesEdited = wikiHelper.editor().getTimesEdited();
        let newLastEditionDatetime = wikiHelper.editor().getLastEditionDateTime();

        expect(newHtml).to.be.equal("<p>" + settingText + "</p>");
        expect(newTimesEdited).to.be.eventually.equal(timesEdited+1);
        expect(newLastEditionDatetime).to.be.not.equal(lastEditionDatetime);

        await utils.common.takeScreenshot("wiki", "home-edition");
    });

    it('attachments', utils.detail.attachmentTesting);

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
