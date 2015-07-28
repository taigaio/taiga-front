var utils = require('../utils');
var wikiHelper = require('../helpers').wiki;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('wiki', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/wiki/home');
        await utils.common.waitLoader();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("wiki", "empty");
    });

    it('add link, follow it, edit and remove everything', async function(){
        // creation
        let timestamp = new Date().getTime();
        let linkText = "Test link" + timestamp;
        let slug = "test-link" + timestamp;
        let newLink = await wikiHelper.links().addLink(linkText);

        //Following
        newLink.click();
        expect(browser.getCurrentUrl()).to.be.eventually.equal('http://localhost:9001/project/project-0/wiki/' + slug);
        await utils.common.waitLoader();
        await utils.common.takeScreenshot("wiki", "new-link-created-with-empty-wiki-page");

        //Removing link
        wikiHelper.links().deleteLink(newLink);
        await utils.common.takeScreenshot("wiki", "deleting-the-created-link");

        // Edition
        let timesEdited = wikiHelper.editor().getTimesEdited();
        let lastEditionDatetime = wikiHelper.editor().getLastEditionDateTime();
        wikiHelper.editor().enabledEditionMode();
        let settingText = "This is the new text" + new Date().getTime();
        wikiHelper.editor().setText(settingText);

        // Checking preview
        wikiHelper.editor().preview();
        await utils.common.takeScreenshot("wiki", "home-edition-preview");

        // Saving
        wikiHelper.editor().save();
        let newHtml = await wikiHelper.editor().getInnerHtml();
        let newTimesEdited = wikiHelper.editor().getTimesEdited();
        let newLastEditionDatetime = wikiHelper.editor().getLastEditionDateTime();
        expect(newHtml).to.be.equal("<p>" + settingText + "</p>");
        expect(newTimesEdited).to.be.eventually.equal(timesEdited+1);
        expect(newLastEditionDatetime).to.be.not.equal(lastEditionDatetime);
        await utils.common.takeScreenshot("wiki", "home-edition");

        // Delete
        await wikiHelper.editor().delete();

        expect(browser.getCurrentUrl()).to.be.eventually.equal('http://localhost:9001/project/project-0/wiki/home');
    })

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

    it('attachments', utils.detail.attachmentTesting);
});
