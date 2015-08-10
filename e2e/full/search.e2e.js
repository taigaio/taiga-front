var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('search page', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/');

        await utils.common.waitLoader();
    });

    it('lightbox', async function() {
        $('#nav-search').click();

        let searchLb = $('div[tg-search-box]');

        await utils.lightbox.open(searchLb);

        utils.common.takeScreenshot('search', 'search-lb');

        await $('#search-text').sendKeys('create');

        searchLb.$('button[type="submit"]').click();

        await browser.waitForAngular();

        let currentUrl = await browser.getCurrentUrl();

        utils.common.takeScreenshot('search', 'usertories');

        expect(currentUrl).to.be.equal('http://localhost:9001/project/project-0/search?text=create');
    });

    describe('tabs', function() {
        it('issues', async function() {
            let option = $$('.search-filter li').get(1).$('a');
            option.click();

            utils.common.takeScreenshot('search', 'issues');

            let active = await utils.common.hasClass(option, 'active');

            expect(active).to.be.true;
        });

        it('tasks', async function() {
            let option = $$('.search-filter li').get(2).$('a');
            option.click();

            utils.common.takeScreenshot('search', 'tasks');

            let active = await utils.common.hasClass(option, 'active');

            expect(active).to.be.true;
        });

        it('wiki', async function() {
            let option = $$('.search-filter li').get(3).$('a');
            option.click();

            utils.common.takeScreenshot('search', 'wiki');

            let active = await utils.common.hasClass(option, 'active');

            expect(active).to.be.true;
        });

        it('userstories', async function() {
            let option = $$('.search-filter li').get(0).$('a');
            option.click();

            let active = await utils.common.hasClass(option, 'active');

            expect(active).to.be.true;
        });
    });

    describe('new search', function() {
        it('change current tab content on typing in the right column', async function() {
            let text = await $$('.table-main').get(0).$('a').getText();

            let searchTerm = element(by.model('searchTerm'));

            searchTerm.clear();

            await searchTerm.sendKeys(text);

            await browser.waitForAngular();

            let count = await $$('.table-main').count();

            expect(count).to.equal(1);
        });
    });
});
