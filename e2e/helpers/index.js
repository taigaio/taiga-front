/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
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
