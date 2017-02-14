var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('home', function() {
    before(async function(){
        browser.get(browser.params.glob.host);

        await utils.common.waitLoader();
        utils.common.takeScreenshot("home", "dashboard");
    });

    it('working on filled', async function() {
        return expect(await $$('.working-on div[tg-duty]').count()).to.be.above(0);
    });

    it('watching filled', async function() {
        return expect(await $$('.watching div[tg-duty]').count()).to.be.above(0);
    });

    it('project list filled', async function() {
        return expect(await $$('.home-project').count()).to.be.above(0);
    });

    describe('projects list', function() {
        before(async function() {
            browser.get(browser.params.glob.host + 'projects/');

            await utils.common.waitLoader();
            utils.common.takeScreenshot("home", "projects");
        });
    });

    describe("project drag and drop", function() {
        var draggedElementText;

        before(async function() {
            browser.get(browser.params.glob.host + 'projects/');

            let dragableElements = element.all(by.css('.list-itemtype-project'));
            let dragElement = dragableElements.get(3);
            let dragElementLink = dragElement.element(by.css('h2 a'));

            await utils.common.waitLoader();

            draggedElementText = await dragElementLink.getText();

            await utils.common.drag(dragElement, dragableElements.get(0));
            await browser.waitForAngular();
        });

        it('projects list has the new order', async function() {
            var firstElement = await $$('.list-itemtype-project h2 a').first().getText();

            expect(firstElement).to.be.equal(draggedElementText);
        });

        it('projects menu has the new order', async function() {
            var firstElementText = await $$('div[tg-dropdown-project-list] ul a span').first().getInnerHtml();

            expect(firstElementText).to.be.equal(draggedElementText);
        });

        after(async function() {
            //restore project position
            let dragableElements = element.all(by.css('.list-itemtype-project'));
            let dragElement = dragableElements.get(0);
            let dragElementLink = dragElement.element(by.css('h2 a'));

            await utils.common.waitLoader();

            draggedElementText = await dragElementLink.getText();

            await utils.common.drag(dragElement, dragableElements.get(3));
            await browser.waitForAngular();
        });

    });
});
