/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

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
          describe('epics', function() {
              let typeIndex = 0;
              let timestamp = new Date().getTime();

              it('create', async function() {
                  let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                  await customFieldsHelper.create(typeIndex, 'test1-text'+timestamp, 'desc1', 1);

                  // debounce :(
                  await utils.notifications.success.open();
                  await utils.notifications.success.close();

                  await customFieldsHelper.create(typeIndex, 'test1-multi'+timestamp, 'desc1', 3);

                  // debounce :(
                  await utils.notifications.success.open();
                  await utils.notifications.success.close();

                  let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                  expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
              });

              it('edit', async function() {
                  customFieldsHelper.edit(typeIndex, 0, 'edit'+timestamp, 'desc2', 2);

                  let open = await utils.notifications.success.open();

                  expect(open).to.be.true;

                  await utils.notifications.success.close();
              });

              it('drag', async function() {
                  let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                  await customFieldsHelper.drag(typeIndex, 0, 1);

                  let nameNew = await customFieldsHelper.getName(typeIndex, 1);

                  expect(nameNew).to.be.equal(nameOld);
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

        describe('userstories', function() {
            let typeIndex = 1;
            let timestamp = new Date().getTime();

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.create(typeIndex, 'test1-text'+timestamp, 'desc1', 1);

                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                await customFieldsHelper.create(typeIndex, 'test1-multi'+timestamp, 'desc1', 3);

                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                await customFieldsHelper.edit(typeIndex, 0, 'edit'+timestamp, 'desc2', 1);

                let open = await utils.notifications.success.open();

                expect(open).to.be.true;

                await utils.notifications.success.close();
            });

            it('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = await customFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.equal(nameOld);
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
            let typeIndex = 2;
            let timestamp = new Date().getTime();

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();
                await customFieldsHelper.create(typeIndex, 'test1-text'+timestamp, 'desc1', 1);
                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                await customFieldsHelper.create(typeIndex, 'test1-multi'+timestamp, 'desc1', 3);
                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                customFieldsHelper.edit(typeIndex, 0, 'edit'+timestamp, 'desc2', 2);

                let open = await utils.notifications.success.open();

                expect(open).to.be.true;

                await utils.notifications.success.close();
            });

            it('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = await customFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.equal(nameOld);
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
            let typeIndex = 3;
            let timestamp = new Date().getTime();

            it('create', async function() {
                let oldCountCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                await customFieldsHelper.create(typeIndex, 'test1-text'+timestamp, 'desc1', 1);

                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                await customFieldsHelper.create(typeIndex, 'test1-multi'+timestamp, 'desc1', 3);

                // debounce :(
                await utils.notifications.success.open();
                await utils.notifications.success.close();

                let countCustomFields = await customFieldsHelper.getCustomFiledsByType(typeIndex).count();

                expect(countCustomFields).to.be.equal(oldCountCustomFields + 2);
            });

            it('edit', async function() {
                customFieldsHelper.edit(typeIndex, 0, 'edit'+timestamp, 'desc2', 2);

                let open = await utils.notifications.success.open();

                expect(open).to.be.true;

                await utils.notifications.success.close();
            });

            it('drag', async function() {
                let nameOld = await customFieldsHelper.getName(typeIndex, 0);

                await customFieldsHelper.drag(typeIndex, 0, 1);

                let nameNew = await customFieldsHelper.getName(typeIndex, 1);

                expect(nameNew).to.be.equal(nameOld);
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
