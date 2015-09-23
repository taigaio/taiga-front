var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project home', function() {
    beforeEach(async function() {
        browser.get(browser.params.glob.host + 'project/project-1/');
        await utils.common.waitLoader();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("project", "home");
    });

    it('go to project', async function() {
        await utils.common.goToFirstProject();
    });

    it('timeline filled', function() {
        expect($$('div[tg-user-timeline-item]').count()).to.be.eventually.above(0);
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
        expect($$('ul.involved-team a').count()).to.be.eventually.above(0);
    });
});
