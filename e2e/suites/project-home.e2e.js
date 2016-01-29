var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project home', function() {
    beforeEach(async function() {
        browser.get(browser.params.glob.host + 'project/project-1/');
        await utils.common.waitLoader();

        await utils.common.takeScreenshot("project", "home-like");

    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("project", "home");
    });

/*
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
*/
    it('unlike', async function() {
        let reset = async function() {
            //reset
            let link = $('tg-like-project-button a');
            let likeActive = await utils.common.hasClass(link, 'active');

            if (!likeActive) {
                link.click();
            }
        };

        await reset();

        let link = $('tg-like-project-button a');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();

        let likeActive = await utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.false;
        expect(likesCounter).to.be.equal(likesCounterOld - 1);
    });

    it('like', async function() {
        let link = $('tg-like-project-button a');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();
        await utils.common.takeScreenshot("project", "home-like");

        let likeActive = await utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.true;
        expect(likesCounter).to.be.equal(likesCounterOld + 1);
    });

    it('unwatch', async function() {
        let link = $('tg-watch-project-button > a');
        let watchOptions = $('tg-watch-project-button .watch-options');
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

        let watchActive = await utils.common.hasClass(link, 'active');
        let watchCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(watchActive).to.be.false;
        expect(watchCounter).to.be.equal(watchCounterOld - 1);
    });

    it('watch', async function() {
        let link = $('tg-watch-project-button > a');
        let watchOptions = $('tg-watch-project-button .watch-options');
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

        let watchActive = await utils.common.hasClass(link, 'active');
        let watchCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        await utils.common.takeScreenshot("project", "home-watch");

        expect(watchActive).to.be.true;
        expect(watchCounter).to.be.equal(watchCounterOld + 1);
    });

});
