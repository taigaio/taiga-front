/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

module.exports.backlog = require("./backlog-helper");
module.exports.taskboard = require("./taskboard-helper");
module.exports.kanban = require("./kanban-helper");
module.exports.team = require("./team-helper");
module.exports.wiki = require("./wiki-helper");
module.exports.detail = require("./detail-helper");
module.exports.usDetail = require("./us-detail-helper");
module.exports.taskDetail = require("./task-detail-helper");
module.exports.adminAttributes = require("./admin-attributes-helper");
module.exports.common = require("./common-helper");
module.exports.adminMemberships = require("./admin-memberships");
module.exports.adminPermissions = require("./admin-permissions");
module.exports.adminIntegrations = require("./admin-integrations");
module.exports.issues = require("./issues-helper");
module.exports.createProject = require("./create-project-helper");
module.exports.epicsDashboard = require("./epics-dashboard-helper");
module.exports.epicDetail = require("./epic-detail-helper");
