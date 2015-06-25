var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe.skip('backlog', function() {
    before(function(){
        browser.get('http://localhost:9001/project/user7-project-example-0/');

        return utils.common.waitLoader().then(function() {
            return utils.common.takeScreenshot('backlog', 'backlog');
        });
    });

    it('create US', function() {
        $('.new-us a').click();

        lightbox.open('div[tg-lb-create-edit-userstory]').then(function() {

        });
    });
});
