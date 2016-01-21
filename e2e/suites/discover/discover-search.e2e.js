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

            discoverHelper.searchFilter(1);

            await htmlChanges();

            let url = await browser.getCurrentUrl();

            let projects = discoverHelper.searchProjects();

            expect(projects.count()).to.be.eventually.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?filter=kanban');
        });

        it('search by text', () => {
            discoverHelper.searchInput().sendKeys('Project Example 0');

            discoverHelper.sendSearch();

            let projects = discoverHelper.searchProjects();
            expect(projects.count()).to.be.eventually.equal(1);
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

            expect(projects.count()).to.be.eventually.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_fans');
        });

        it('clear', () => {
            discoverHelper.clearOrder();

            let orderSelector = discoverHelper.orderSelectorWrapper();

            expect(orderSelector.isPresent()).to.be.eventually.equal(false);
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

            expect(projects.count()).to.be.eventually.above(0);
            expect(url).to.be.equal(browser.params.glob.host + 'discover/search?order_by=-total_activity');
        });

        it('clear', () => {
            discoverHelper.clearOrder();

            let orderSelector = discoverHelper.orderSelectorWrapper();

            expect(orderSelector.isPresent()).to.be.eventually.equal(false);
        });
    });
});
