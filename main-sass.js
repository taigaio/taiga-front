exports.files = function () {
    var base = process.cwd() + "/tmp/styles/";

    var files  = [
        // Codehilite
        'vendor/codehilite.github',

        //#################################################
        //             Layout
        //#################################################

        'layout/reset',
        'layout/base',
        'layout/animation',
        'layout/typography',
        'layout/login',
        'layout/invitation',
        'layout/elements',
        'layout/forms',
        'layout/not-found',
        'layout/backlog',
        'layout/taskboard',
        'layout/us-detail',
        'layout/admin-memberships',
        'layout/admin-project-values',
        'layout/project-colors',
        'layout/kanban',
        'layout/issues',
        'layout/wiki',
        'layout/wiki-edit',
        'layout/team',

        //#################################################
        //             components
        //#################################################

        'components/buttons',
        'components/avatar',
        'components/summary',
        'components/popover',
        'components/tag',
        'components/filter',
        'components/taskboard-task',
        'components/kanban-task',
        'components/notification-message',
        'components/basic-table',
        'components/paginator',
        'components/watchers',
        'components/level',
        'components/created-by',
        'components/wysiwyg',
        'components/select-color',
        'components/loader',
        'components/loading-bar',
        'components/help-notion-button',
        'components/beta',
        'components/markitup',
        'components/markdown-help',
        'components/popover-points',


        //#################################################
        //             Modules
        //#################################################

        //Common modules
        'modules/common/assigned-to',
        'modules/common/nav',
        'modules/common/projects-nav',
        'modules/common/lightbox',
        'modules/common/colors-table',
        'modules/common/category-config',
        'modules/common/attachments',
        'modules/common/related-tasks',
        'modules/common/history',
        'modules/common/wizard',
        'modules/common/external-reference',
        'modules/common/custom-fields',

        //Project modules
        'modules/home-projects-list',
        'modules/home-project',
        'modules/create-project',

        //Issues modules
        'modules/issues/issues-table',

        //Kanban modules
        'modules/kanban/kanban-table',

        //Search modules
        'modules/search/search-filter',
        'modules/search/search-result-table',
        'modules/search/search-in',

        //Filters modules
        'modules/filters/filters',
        'modules/filters/list-filters',
        'modules/filters/filter-tags',

        //Backlog modules
        'modules/backlog/sprints',
        'modules/backlog/burndown',
        'modules/backlog/backlog-table',
        'modules/backlog/taskboard-table',

        //Login modules
        'modules/auth/login-form',
        'modules/auth/register-form',
        'modules/auth/forgot-form',
        'modules/auth/change-password-from-recovery',
        'modules/auth/cancel-account',

        //Wiki modules
        'modules/wiki/wiki-nav',
        'modules/wiki/wiki-summary',

        //modules admin
        'modules/admin/admin-menu',
        'modules/admin/admin-common',
        'modules/admin/admin-submenu',
        'modules/admin/admin-submenu-roles',
        'modules/admin/admin-roles',
        'modules/admin/admin-functionalities',
        'modules/admin/admin-project-export',
        'modules/admin/admin-membership-table',
        'modules/admin/admin-project-profile',
        'modules/admin/default-values',
        'modules/admin/admin-custom-fields',
        'modules/admin/project-values',
        'modules/admin/third-parties',
        'modules/admin/admin-third-parties-webhooks',
        'modules/admin/contrib',

        //Modules user Settings
        'modules/user-settings/user-profile',
        'modules/user-settings/user-change-password',
        'modules/user-settings/mail-notifications-table',

        //Team
        'modules/team/team-filters',
        'modules/team/team-table',

        //#################################################
        //             Help
        //#################################################

        'modules/help/lightbox-generic-notion',

        //#################################################
        //             Shame
        //#################################################

        'shame/shame',
    ];

    files = files.map(function (file) {
        return base + file + ".css";
    });

    return files;
}();
