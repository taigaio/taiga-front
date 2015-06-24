var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project home', function() {
    before(function(){
        browser.get('http://localhost:9001/');

        return utils.common.waitLoader().then(function() {
            return utils.common.takeScreenshot("project", "home");
        });
    });

    it('go to project', function() {
        browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();
        $$('div[tg-dropdown-project-list] ul a').first().click();
    });

    it('timeline filled', function() {
        return expect($$('div[tg-user-timeline-item]').count()).to.be.eventually.above(0);
    });

    it('timeline pagination', function(done) {
        $$('div[tg-user-timeline-item]')
            .count()
            .then(function(startTotal) {
                return browser.executeScript('window.scrollTo(0,document.body.scrollHeight)')
                    .then(function() {
                        return browser.waitForAngular();
                    })
                    .then(function() {
                        return $$('div[tg-user-timeline-item]').count();
                    })
                    .then(function(endTotal) {
                        return startTotal < endTotal;
                    });
            })
            .then(function(hasMoreItems) {
                expect(hasMoreItems).to.be.equal(true);

                done();
            });
    });

    it('team filled', function() {
        return expect($$('ul.involved-team a').count()).to.be.eventually.above(0);
    });
});
