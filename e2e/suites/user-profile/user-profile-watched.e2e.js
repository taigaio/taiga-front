/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var helper = require('../../helpers/user-profile-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('user profile - watched', function() {
    describe('current user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile');

            await utils.common.waitLoader();

            $$('.tab').get(3).click();

            await browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-watched');
        });

        it('watched tab', async function() {
            let watchedCount = await $$('div[infinite-scroll] > div').count();

            expect(watchedCount).to.be.above(0);
        });

        it('watched tab - pagination', async function() {
            let startTotal = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await htmlChanges();

            let endTotal = await $$('div[infinite-scroll] > div').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });

        it('watched tab - filter projects', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(1).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });


        it('watched tab - filter epics', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(2).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter user stories', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(3).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter tasks', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(4).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter issues', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(5).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter by query', async function() {
            let allItems = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            $('div.searchbox > input').sendKeys('test');
            await htmlChanges();

            let filteredItems = await $$('div[infinite-scroll] > div').count();

            expect(allItems).to.be.not.equal(filteredItems);

            htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await utils.common.clear($('div.searchbox > input'));
            await htmlChanges();

            filteredItems = await $$('div[infinite-scroll] > div').count();

            expect(allItems).to.be.equal(filteredItems);
        });
    });

    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile/user7');

            await utils.common.waitLoader();

            $$('.tab').get(4).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-watched');
        });

        it('watched tab', async function() {
            let watchedCount = await $$('div[infinite-scroll] > div').count();

            expect(watchedCount).to.be.above(0);
        });

        it('watched tab - pagination', async function() {
            let startTotal = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await htmlChanges();

            let endTotal = await $$('div[infinite-scroll] > div').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });

        it('watched tab - filter projects', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(1).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter epics', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(2).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter user stories', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(3).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter tasks', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(4).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter issues', async function() {
            let allItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            await $$('div.filters > a').get(5).click();

            await browser.waitForAngular();

            let filteredItems = await $('div[infinite-scroll]').getAttribute("innerHTML");

            expect(allItems).to.be.not.equal(filteredItems);
        });

        it('watched tab - filter by query', async function() {
            let allItems = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            $('div.searchbox > input').sendKeys('test');
            await htmlChanges();

            let filteredItems = await $$('div[infinite-scroll] > div').count();

            expect(allItems).to.be.not.equal(filteredItems);

            htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await utils.common.clear($('div.searchbox > input'));
            await htmlChanges();

            filteredItems = await $$('div[infinite-scroll] > div').count();

            expect(allItems).to.be.equal(filteredItems);
        });
    });
});
