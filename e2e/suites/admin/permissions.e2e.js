/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');

var adminPermissionsHelper = require('../../helpers').adminPermissions;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('admin - roles', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/roles');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('permissions', 'permissions');
    });

    it('new role', async function() {
        let oldRolesCount = await adminPermissionsHelper.getRoles().count();

        await adminPermissionsHelper.newRole('test');

        let newRolesCount = await adminPermissionsHelper.getRoles().count();

        expect(newRolesCount).to.be.equal(oldRolesCount + 1);
    });

    it('edit role name', async function() {
        await adminPermissionsHelper.editRole('2');

        expect(utils.notifications.success.open()).to.be.eventually.true;

        await utils.notifications.success.close();
    });

    it('toggle, estimation role', async function() {
        adminPermissionsHelper.toggleEstimationRole();

        expect(utils.notifications.success.open()).to.be.eventually.true;

        await utils.notifications.success.close();
    });

    it('toggle, category permission', async function() {
        await adminPermissionsHelper.openCategory(0);

        let permission = await adminPermissionsHelper.getPermissionsCategory(0).get(0);
        let oldValue = await adminPermissionsHelper.getCategoryPermissionValue(permission);

        adminPermissionsHelper.toggleCategoryPermission(permission);

        await utils.notifications.success.open();

        let newValue = await adminPermissionsHelper.getCategoryPermissionValue(permission);

        expect(newValue).not.be.equal(oldValue);

        await utils.notifications.success.close();
    });

    it('delete', async function() {
        let oldRolesCount = await adminPermissionsHelper.getRoles().count();

        adminPermissionsHelper.delete();

        let el = $('.lightbox-ask-choice');

        await utils.lightbox.open(el);

        utils.common.takeScreenshot('attributes', 'delete-type');

        el.$('.button-green').click();

        let newRolesCount = await adminPermissionsHelper.getRoles().count();

        expect(newRolesCount).to.be.equal(oldRolesCount - 1);
    });
});
