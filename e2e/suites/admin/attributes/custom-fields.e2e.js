var utils = require('../../../utils');
var customFieldsHelper = require('../../../helpers/custom-fields-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('custom-fields', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/project-3/admin/project-values/custom-fields');
        await utils.common.waitLoader();

        utils.common.takeScreenshot('attributes', 'custom-fields');
    });

    describe('create custom fields', function() {
        describe('userstories', function() {
            let typeIndex = 0;

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.create(typeIndex, 'test1-text', 'desc1', 1);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2000);

                await customFieldsHelper.create(typeIndex, 'test1-multi', 'desc1', 3);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2000);

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                await customFieldsHelper.edit(typeIndex, 0, 'edit', 'desc2', 1);

                let notification = await utils.notifications.success.open();

                expect(notification).to.be.true;
            });

            it.skip('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = awcustomFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.eventually.equal(nameOld);
            });

            it('delete', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.delete(typeIndex, 0);

                await browser.wait(async function() {
                    let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                    return countCustomFields === oldCountCustomFields - 1;
                }, 4000);
            });
        });

        describe('tasks', function() {
            let typeIndex = 1;

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.create(typeIndex, 'test1-text', 'desc1', 1);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2500);

                await customFieldsHelper.create(typeIndex, 'test1-multi', 'desc1', 3);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2500);

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                customFieldsHelper.edit(typeIndex, 0, 'edit', 'desc2', 2);

                expect(utils.notifications.success.open()).to.be.eventually.true;
            });

            it.skip('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = customFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.eventually.equal(nameOld);
            });

            it('delete', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.delete(typeIndex, 0);

                await browser.wait(async function() {
                    let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                    return countCustomFields === oldCountCustomFields - 1;
                }, 4000);
            });
        });

        describe('issues', function() {
            let typeIndex = 2;

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.create(typeIndex, 'test1-text', 'desc1', 1);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2000);

                await customFieldsHelper.create(typeIndex, 'test1-multi', 'desc1', 3);

                // debounce :(
                await utils.notifications.success.open();
                await browser.sleep(2000);

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                customFieldsHelper.edit(typeIndex, 0, 'edit', 'desc2', 2);

                expect(utils.notifications.success.open()).to.be.eventually.true;
            });

            it.skip('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = customFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.eventually.equal(nameOld);
            });

            it('delete', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.delete(typeIndex, 0);

                await browser.wait(async function() {
                    let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                    return countCustomFields === oldCountCustomFields - 1;
                }, 4000);
            });
        });
    });
});
