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

    it('working on filled', function() {
        return expect($$('.working-on div[tg-duty]').count()).to.be.eventually.above(0);
    });

    it('watching filled', function() {
        return expect($$('.watching div[tg-duty]').count()).to.be.eventually.above(0);
    });

    it('project list filled', function() {
        return expect($$('.home-project-list-single').count()).to.be.eventually.above(0);
    });

    describe('projects list', function() {
        before(async function() {
            browser.get(browser.params.glob.host + 'projects/');

            await utils.common.waitLoader();
            utils.common.takeScreenshot("home", "projects");
        });

        it('open create project lightbox', function() {
            $('.master .create-project-btn').click();

            return expect(utils.lightbox.open('div[tg-lb-create-project]')).to.be.eventually.equal(true);
        });

        it('close create project lightbox', function() {
            $('div[tg-lb-create-project] .icon-delete').click();

            return expect(utils.lightbox.close('div[tg-lb-create-project]')).to.be.eventually.equal(true);
        });
    });

    describe("project drag and drop", function() {
        var draggedElementText;

        before(async function() {
            browser.get(browser.params.glob.host + 'projects/');

            let dragableElements = element.all(by.css('.project-list-single'));
            let dragElement = dragableElements.get(3);
            let dragElementLink = dragElement.element(by.css('a'));

            await utils.common.waitLoader();

            draggedElementText = await dragElementLink.getText();

            await utils.common.drag(dragElement, dragableElements.get(0));
            await browser.waitForAngular();
        });

        utils.common.browserSkip('firefox', 'projects list has the new order', function() {
            var firstElement = $$('.project-list-single a').first().getText();

            expect(firstElement).to.be.eventually.equal(draggedElementText);
        });

        utils.common.browserSkip('firefox', 'projects menu has the new order', function() {
            var firstElementText = $$('div[tg-dropdown-project-list] ul a').first().getInnerHtml();

            expect(firstElementText).to.be.eventually.equal(draggedElementText);
        });

        after(async function() {
            //restore project position
            let dragableElements = element.all(by.css('.project-list-single'));
            let dragElement = dragableElements.get(0);
            let dragElementLink = dragElement.element(by.css('a'));

            await utils.common.waitLoader();

            draggedElementText = await dragElementLink.getText();

            await utils.common.drag(dragElement, dragableElements.get(3));
            await browser.waitForAngular();
        });

    });
});
