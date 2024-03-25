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

describe('user profile - likes', function() {
    describe('current user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile');

            await utils.common.waitLoader();

            $$('.tab').get(1).click();

            await browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-likes');
        });

        it('likes tab', async function() {
            let likesCount = await $$('div[infinite-scroll] > div').count();

            expect(likesCount).to.be.above(0);
        });

        it('likes tab - filter by query', async function() {
            let projectNames = await helper.getProjectsNames();
            let projectName = projectNames[0].substr(projectNames[0].length - 1);

            let allItems = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            $('div.searchbox > input').sendKeys(projectName);
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

            $$('.tab').get(2).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-likes');
        });

        it('likes tab', async function() {
            let likesCount = await $$('div[infinite-scroll] > div').count();

            expect(likesCount).to.be.above(0);
        });

        it('likes tab - filter by query', async function() {
            let allItems = await $$('div[infinite-scroll] > div').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            $('div.searchbox > input').sendKeys('proj 2');
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
