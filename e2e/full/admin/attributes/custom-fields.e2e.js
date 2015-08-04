var utils = require('../../../utils');

var adminAttributesHelper = require('../../../helpers').adminAttributes;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('attributes - custom fields', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/admin/project-values/custom-fields');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('attributes', 'custom-fields');
    });

    it('new', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getCustomFieldsForm(formWrapper);

        await form.name().sendKeys('test test');

        await form.save();

        await browser.waitForAngular();

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count + 1);
    });

    it('duplicate', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getCustomFieldsForm(formWrapper);

        await form.name().sendKeys('test test');

        await form.save();

        await browser.waitForAngular();

        let newCount = await rows.count();

        let errors = await form.errors().count();

        utils.common.takeScreenshot('attributes', 'status-error');

        expect(errors).to.be.equal(1);
        expect(newCount).to.be.equal(count);
    });

    it('delete', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();

        let count = await rows.count();

        let row = rows.get(count - 1);

        section.delete(row);

        let el = $('.lightbox-generic-ask');

        await utils.lightbox.open(el);

        utils.common.takeScreenshot('attributes', 'delete-custom-field');

        el.$('.button-green').click();

        await utils.lightbox.close(el);

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count - 1);
    });

    it('edit', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let row = rows.get(0);

        await section.edit(row);

        let form = adminAttributesHelper.getCustomFieldsForm(row.$('form'));

        let newCfName = 'test test' + Date.now();
        await form.name().clear();
        await form.name().sendKeys(newCfName);

        await form.save();

        await browser.waitForAngular();

        let newCfs = await adminAttributesHelper.getCustomFieldsNames(section.el);

        expect(newCfs.indexOf(newCfName)).to.be.not.equal(-1);
    });

    it('drag', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let cfs = await adminAttributesHelper.getCustomFieldsNames(section.el);

        await utils.common.drag(rows.get(0), rows.get(2));

        let newCfs = await adminAttributesHelper.getCustomFieldsNames(section.el);

        expect(cfs[0]).to.be.equal(newCfs[1]);
    });
});
