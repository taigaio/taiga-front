/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var helper = module.exports;

helper.getProjectsNames = function() {
    return $$('.list-itemtype-project-name').getText();
};

helper.waitLoader = function() {
    return browser.wait(function() {
        return $('.spin').isPresent();
    }, 5000);
};
