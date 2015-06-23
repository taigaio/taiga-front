var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('home', function() {
    before(function(){
        browser.get('http://localhost:9001/');

        return utils.common.waitLoader().then(function() {
            return utils.common.takeScreenshot("home", "dashboard");
        });
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
        before(function() {
            browser.get('http://localhost:9001/projects/');

            return utils.common.waitLoader().then(function() {
                return utils.common.takeScreenshot("home", "projects");
            });
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

        before(function() {
            browser.get('http://localhost:9001/projects/');

            var dragableElements = element.all(by.css('.project-list-single'));
            var dragElement = dragableElements.get(3);
            var dragElementLink = dragElement.element(by.css('a'));

            return utils.common.waitLoader()
                .then(function() {
                    return dragElementLink.getText()
                })
                .then(function(_draggedElementText_) {
                    draggedElementText = _draggedElementText_;

                    return utils.common.drag(dragElement, dragableElements.get(0))
                });
        });

        it('projects list has the new order', function() {
            var firstElement = $$('.project-list-single a').first().getText();

            expect(firstElement).to.be.eventually.equal(draggedElementText);
        });

        it('projects menu has the new order', function() {
            var firstElementText = $$('div[tg-dropdown-project-list] ul a').first().getInnerHtml();

            expect(firstElementText).to.be.eventually.equal(draggedElementText);
        });
    });
});
