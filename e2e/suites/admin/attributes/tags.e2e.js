var utils = require('../../../utils');

var adminAttributesHelper = require('../../../helpers').adminAttributes;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('attributes - tags', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-values/tags');

        await adminAttributesHelper.waitLoad();

        utils.common.takeScreenshot('attributes', 'tags');
    });

    it('edit', async function() {
        let section = adminAttributesHelper.getTagsSection(0);
        let rows = section.rows();
        let row = rows.get(0);

        let form = adminAttributesHelper.getGenericForm(row.$('form'));

        var colorBox = form.colorBox();
        await colorBox.click();
        await form.colorText().clear();
        await form.colorText().sendKeys('#000000');
        await browser.actions().sendKeys(protractor.Key.ENTER).perform();

        await browser.waitForAngular();

        section = adminAttributesHelper.getTagsSection(0);
        rows = section.rows();
        row = rows.get(0);
        let backgroundColor = await row.$$('.edition .current-color').get(0).getCssValue('background-color');
        expect(backgroundColor).to.be.equal('rgba(0, 0, 0, 1)');
        utils.common.takeScreenshot('attributes', 'tag edited is black');
    });

    it('filter', async function() {
        let tagsFilter = adminAttributesHelper.getTagsFilter();
        await tagsFilter.clear();
        await tagsFilter.sendKeys('ad');
        await browser.waitForAngular();

        let section = adminAttributesHelper.getTagsSection(0);
        let rows = section.rows();
        let count = await rows.count();
        expect(count).to.be.equal(2);
    });


});
