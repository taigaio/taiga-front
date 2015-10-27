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

    it('like', async function() {
        let link = $('tg-like-button a');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();
        await utils.common.takeScreenshot("project", "home-like");

        let likeActive = utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.eventually.true;
        expect(likesCounter).to.be.equal(likesCounterOld + 1);
    });

    it('unlike', async function() {
        let link = $('tg-like-button a');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();

        let likeActive = utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.eventually.false;
        expect(likesCounter).to.be.equal(likesCounterOld - 1);
    });

    it('watch', async function() {
        let link = $('tg-watch-button > a');
        let watchOptions = $('tg-watch-button .watch-options');
        let watchCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();

        await browser.wait(async () => {
            return !await utils.common.hasClass(watchOptions, 'hidden');
        }, 4000);

        watchOptions.$$('a').first().click();

        await browser.wait(async () => {
            return await utils.common.hasClass(watchOptions, 'hidden');
        }, 4000);

        let watchActive = utils.common.hasClass(link, 'active');
        let watchCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        await utils.common.takeScreenshot("project", "home-watch");

        expect(watchActive).to.be.eventually.true;
        expect(watchCounter).to.be.equal(watchCounterOld + 1);
    });

    it('unwatch', async function() {
        let link = $('tg-watch-button > a');
        let watchOptions = $('tg-watch-button .watch-options');
        let watchCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();

        await browser.wait(async () => {
            return !await utils.common.hasClass(watchOptions, 'hidden');
        }, 4000);

        watchOptions.$$('a').last().click();

        await browser.wait(async () => {
            return await utils.common.hasClass(watchOptions, 'hidden');
        }, 4000);

        let watchActive = utils.common.hasClass(link, 'active');
        let watchCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(watchActive).to.be.eventually.false;
        expect(watchCounter).to.be.equal(watchCounterOld - 1);
    });
});
