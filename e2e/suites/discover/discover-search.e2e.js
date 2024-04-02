/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var discoverHelper = require('../../helpers/discover-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;


describe('discover search', () => {
    before(async () => {
        browser.get(browser.params.glob.host + 'discover/search');
        await utils.common.waitLoader();
    });

    it('screenshot', async () => {
        await utils.common.takeScreenshot("discover", "discover-search");
    });

    describe('top bar', async () => {
        after(async () => {
            browser.get(browser.params.glob.host + 'discover/search');
            await utils.common.waitLoader();
        });

        it('filters', async () => {
            let htmlChanges = await utils.common.outerHtmlChanges(discoverHelper.searchProjectsList());

            discoverHelper.searchFilter(3);

            let url = await browser.getCurrentUrl();

            let projects = discoverHelper.searchProjects();

            expect(await projects.count()).to.be.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?filter=people');
        });

        it('search by text', async () => {
            let projects = discoverHelper.searchProjects();
            let projectTitle = projects.get(0).$('h2 a').getText();

            discoverHelper.searchInput().sendKeys(projectTitle);

            discoverHelper.sendSearch();

            projects = discoverHelper.searchProjects();
            expect(await projects.count()).to.be.equal(1);
        });
    });

    describe('most liked', async () => {
        after(async () => {
            browser.get(browser.params.glob.host + 'discover/search');
            await utils.common.waitLoader();
        });

        it('default', async () => {
            discoverHelper.mostLiked();

            utils.common.takeScreenshot("discover", "discover-search-filter");

            let url = await browser.getCurrentUrl();

            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_fans_last_week');
        });

        it('filter', async () => {
            discoverHelper.searchOrder(3);

            let projects = discoverHelper.searchProjects();

            let url = await browser.getCurrentUrl();

            expect(await projects.count()).to.be.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_fans');
        });

        it('clear', async () => {
            discoverHelper.clearOrder();

            let orderSelector = discoverHelper.orderSelectorWrapper();

            expect(await orderSelector.isPresent()).to.be.equal(false);
        });
    });

    describe('most active', async () => {
        after(async () => {
            browser.get(browser.params.glob.host + 'discover/search');
            await utils.common.waitLoader();
        });

        it('default', async () => {
            discoverHelper.mostActived();

            utils.common.takeScreenshot("discover", "discover-search-filter");

            let url = await browser.getCurrentUrl();

            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_activity_last_week');
        });

        it('filter', async () => {
            discoverHelper.searchOrder(3);

            let projects = discoverHelper.searchProjects();

            let url = await browser.getCurrentUrl();

            expect(await projects.count()).to.be.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_activity');
        });

        it('clear', async () => {
            discoverHelper.clearOrder();

            let orderSelector = discoverHelper.orderSelectorWrapper();

            expect(await orderSelector.isPresent()).to.be.equal(false);
        });
    });
});
