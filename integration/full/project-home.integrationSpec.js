var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project home', function() {
    before(async function(){
        browser.get('http://localhost:9001/');

        await utils.common.waitLoader();
        await utils.common.takeScreenshot("project", "home");
    });

    it('go to project', function() {
        browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();
        $$('div[tg-dropdown-project-list] ul a').first().click();
    });

    it('timeline filled', function() {
        return expect($$('div[tg-user-timeline-item]').count()).to.be.eventually.above(0);
    });

    it('timeline pagination', async function() {
        let startTotal = await $$('div[tg-user-timeline-item]').count();

        await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
        await browser.waitForAngular();

        let endTotal = await $$('div[tg-user-timeline-item]').count();

        let hasMoreItems = startTotal < endTotal;

        expect(hasMoreItems).to.be.equal(true);
    });

    it('team filled', function() {
        return expect($$('ul.involved-team a').count()).to.be.eventually.above(0);
    });
});
