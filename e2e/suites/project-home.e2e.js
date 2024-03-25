/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project home', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/project-1/');
        await utils.common.waitLoader();

        await utils.common.takeScreenshot("project", "home-like");

        //reset
        let link = $('tg-like-project-button button');
        let likeActive = await utils.common.hasClass(link, 'active');

        if (!likeActive) {
            link.click();
        }

        await browser.waitForAngular();
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
        let link = $('tg-like-project-button button');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();

        let likeActive = await utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.false;
        expect(likesCounter).to.be.equal(likesCounterOld - 1);
    });

    it('like', async function() {
        let link = $('tg-like-project-button button');
        let likesCounterOld = parseInt(await link.$('.track-button-counter').getText(), 10);

        link.click();

        await browser.waitForAngular();
        await utils.common.takeScreenshot("project", "home-like");

        let likeActive = await utils.common.hasClass(link, 'active');
        let likesCounter = parseInt(await link.$('.track-button-counter').getText(), 10);

        expect(likeActive).to.be.true;
        expect(likesCounter).to.be.equal(likesCounterOld + 1);
    });

    it('contact project', async function() {
        $('tg-contact-project-button > .e2e-contact-team').click();

        let contactProjectLb = $('div[tg-lb-contact-project]');

        await utils.lightbox.open(contactProjectLb);
        await utils.common.takeScreenshot("project", "contact-form");

        let form = $('.e2e-lightbox-contact-project');

        await form.$('.e2e-lightbox-contact-project-message').sendKeys('contact');
        form.$('.e2e-lightbox-contact-project-button').click();
        await utils.notifications.success.open();
        await utils.notifications.success.close();
    });

    it('unwatch', async function() {
        let link = $('tg-watch-project-button > button');
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
        let link = $('tg-watch-project-button > button');
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

    it('blocked project', async function() {
      browser.get(browser.params.glob.host + 'project/project-6/');
      await utils.common.waitLoader();
      await utils.common.takeScreenshot("project", "blocked-project");
      expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'blocked-project/project-6/');
    });

});
