# Changelog

## Unreleased

## 3.4.1 (2018-08-21)

### Misc

- Add auto CTRL+C in admin icon for reports URL's.
- Minor bug fixes.

## 3.4.0 Pinus contorta (2018-08-13)

### Features

- Due dates administration (https://tree.taiga.io/project/taiga/issue/3069)
- Issues to sprint (https://tree.taiga.io/project/taiga/issue/1181)
- Link US to Epics - https://tree.taiga.io/project/taiga/issue/4732
- New lightbox - https://tree.taiga.io/project/taiga/issue/3167

## 3.3.16 (2018-08-08)

- Fix another bug related with ordering US.

## 3.3.15 (2018-08-06)

### Misc

- Filter by cards to find position in Kanban.

## 3.3.14 (2018-08-06)

### Misc

- Move US to the end when status archived and hidden

- Fix US order when move it

## 3.3.13 (2018-07-05)

### Misc

- Add assigned users filters.

- Minor bug fixes.

## 3.3.12 (2018-06-27)

### Misc

- Temporary remove assigned users filters.

## 3.3.11 (2018-06-27)

### Misc

- Fix debounce load US's
- Fix RTL style bug

## 3.3.10 (2018-06-21)

### Misc

- Fix style bug.

## 3.3.9 (2018-06-21)

### Misc

- Update locales.

- Improve RTL styles.

## 3.3.8 (2018-06-14)

### Features

- Add Right-To-Left (RTL) support.

### Misc

- Update locales.

## 3.3.7 (2018-05-31)

### Misc

- Fix bug unable to sign up when no privacyPolicyUrl or termsOfServiceUrl
  settings were defined.

- Update locales.

## 3.3.6 (2018-05-24)

### Misc

- Minor bug fix regarding GDPR notification.

## 3.3.5 (2018-05-24)

### Misc

- Update locales.

## 3.3.4 (2018-05-24)

### Misc

- Add features to fulfill GDPR.

## 3.3.3 (2018-05-10)

### Misc

- Add Persian (Iran) language.
- Update locales.
- Minor bug fixes.

## 3.3.2 (2018-04-30)

### Misc

- Minor bug fixes.

## 3.3.1 (2018-04-30)

### Misc

- Minor bug fixes.

## 3.3.0 Picea mariana (2018-04-26)

### Features

- Add "live notifications" to Taiga:
    - Add configuration in profile area.
- Add "due date" in US, Tasks and Issues.
- Add multiple assignement only in US.
- Delete cards in Kanban and sprint Taskboard.

## 3.2.3 (2018-04-04)

### Misc

- Minor bug fixes.
- Update locales.

## 3.2.2 (2018-03-15)

### Misc

- Minor bug fixes.

## 3.2.1 (2018-03-08)

### Misc
- Fix multiple drag in macOS.
- Repair collapsed column style.

## 3.2.0 Betula nana (2018-03-07)

### Features
- Emojis support on subjects and tags.
- Add "confirm dialog" before closing edit lightboxes.
- Wiki activity hidden by default.
- Allow ascending votes ordering in issues list.
- Add multiple drag in Kanban.
- Show US counter and wip limit in Kanban columns title.
- Add role filtering in US.


## 3.1.3 (2018-02-28)

### Features
- Minor bug fixes.


## 3.1.0 Perovskia Atriplicifolia (2017-03-10)

### Features
- New project creation form: Now you can:
    - duplicate a project.
    - import from Taiga.
    - import from Trello.
    - import from Jira.
    - import from GitHub.
    - import from Asana.
- Improve add-members form: Now users can select between their contacts or type an email.
- Contact with the project: if the projects have this module enabled Taiga users can contact them.
- Velocity forecasting. Create sprints according to team velocity.
- Add new wysiwyg editor (like the Medunm editor) with emojis, local storage changes, mentions...
- Add rich text custom fields (with a wysiwyg editor like descreption or comments).
- Add thumbnails and preview for:
    - PSD files.
    - SVG files.
- i18n:
    - Add japanese (ja) translation.
    - Add korean (ko) translation.
    - Add chinese simplified (zh-Hans) translation.

### Misc
- Lots of small and not so small bugfixes.
- Remove bower, now use only npm packages.


## 3.0.0 Stellaria Borealis (2016-10-02)

### Features
- Add Epics.
- Add the tribe button to link stories from tree.taiga.io with gigs in tribe.taiga.io.
- Show a confirmation notice when you exit edit mode by pressing ESC in the markdown inputs.
- Errors (not found, server error, permissions and blocked project) don't change the current url.
- Neew Attachments image slider in preview mode.
- New admin area to edit the tag colors used in your project.
- Set color when add a new tags to epics, stories, tasks or issues.
- Display the current user (me) at first in assignment lightbox (thanks to [@mikaoelitiana](https://github.com/mikaoelitiana))
- Divide the user dashboard in two columns in large screens.
- Upvote and downvote issues from the issues list.
- Show points per role in statsection of the taskboard panel. (thanks to [@fmartingr](https://github.com/fmartingr))
- Show a funny randon animals/color for users with no avatar (like project logos).
- Show Open Sprints in the left navigation menu (backlog submenu).
- Filters:
    - Refactor the filter module.
    - Add filters in the kanban panel.
    - Add filter in the sprint taskboard panel.
- Cards UI improvements:
    - Add zoom levels.
    - Show information according the zoom level.
    - Show voters, watchers, taks and attachments.
    - Improve performance.
- Comments:
    - Add a new permissions to allow add comments instead of use the existent modify permission for this purpose.
    - Ability to edit comments, view edition history and redesign comments module UI.
- Wiki:
    - Drag & Drop ordering for wiki links.
    - Add a list of all wiki pages
    - Add Wiki history
- Third party integrations:
    - Included gogs as builtin integration.
- i18n:
  - Add norwegian Bokmal (nb) translation.

### Misc
- Lots of small and not so small bugfixes.


## 2.1.0 Ursus Americanus (2016-05-03)

### Features
- Add sprint title on search results for user stories (thanks to [@everblut](https://github.com/everblut))

### Misc
- Lots of small and not so small bugfixes.


## 2.0.0 Pulsatilla Patens (2016-04-04)

### Features
- Ability to create url custom fields. (thanks to [@astagi](https://github.com/astagi)).
- Blocked projects support
- Moved from iconfont to SVG sprite icon system and redesign.
- Redesign 'Admin > Project > Modules' panel.
- Add badge to project owners
- Limit of user per project.
- Redesign of the create project wizard
- Transfer project ownership

### Misc
- Lots of small and not so small bugfixes.


## 1.10.0 Dryas Octopetala (2016-01-30)

### Features
- New design for the detail pages slidebar.
- Added 'Assign to me' button in User Stories, Tasks and Issues detail pages. (thanks to [@allistera](https://github.com/allistera)).
- Attachments:
    - Upload attachments on US/issue/task lightbox.
    - Attachments image gallery view mode in detail pages.
    - Drag files from desktop to attachments section.
    - Drag files from desktop in wysiwyg textareas.
- Project:
    - Add a logo to your project.
    - Denotes that your project is looking for people and add an explanation.
- Discover section:
    - List most liked and most active project (last week/month/year or all time).
    - List featured project.
    - Search projects:
        - Full text search with priorities over title, tags and description fields.
        - Order results alphabeticaly, by most liked or more actived.
        - Filter by 'use kanban', 'use scrum' or 'looking for people'.
- i18n.
  - Add swedish (sv) translation.
  - Add turkish (tr) translation.

### Misc
- Sticky project navigation bar.
- Lots of small and not so small bugfixes.


## 1.9.1 Taiga Tribe (2016-01-05)

### Features
- [118n] Now taiga plugins can be translatable.
- New Taiga plugins system.
- Now superadmins can send notifications (live announcement) to the user (through taiga-events).

### Misc
- Statics folder hash to prevent cache problems when a new version is released.
- Implement websockets heartbeat messages system for taiga-events.
- Lots of small and not so small bugfixes.


## 1.9.0 Abies Siberica (2015-11-02)

### Features
- Ability to create single-line or multi-line custom fields. (thanks to [@artlepool](https://github.com/artlepool)).
- Ability to date custom fields. (thanks to [@artlepool](https://github.com/artlepool)).
- Add custom videoconference system.
- Make burndown chart collapsible at the backlog panel.
- Ability to choose a theme (thanks to [@astagi](https://github.com/astagi)).
- Inline viewing of image attachments (thanks to [@brettp](https://github.com/brettp)).
- Autocomplete for usernames, user stories, tasks, issues, and wiki pages in text areas (thanks to [@brettp](https://github.com/brettp)).
- Support authentication via Application Tokens.
- User onboarding: improve placeholders and add joyriders.
- i18n.
  - Add italian (it) translation.
  - Add polish (pl) translation.
  - Add portuguese (Brazil) (pt_BR) translation.
  - Add russian (ru) translation.

### Misc
- Improve performance: Show cropped images in timelines.
- Caps lock warning in login and register form.
- Lots of small and not so small bugfixes.


## 1.8.0 Saracenia Purpurea (2015-06-18)

### Features
- Menus
    - New User menu
    - New project menu design
- Home
    - Change home page for logged users, show a user dashboard with `working on` and `watching` sections.
- Proyects privacity
    - Enabled public projects
    - Improve SEO, fix meta tags and added social meta tags
- About project detail
    - New projects list design
    - New project detail page design
    - Add project timeline
- User profile
    - Now, access to edit user settings is out of a project
    - New User profile view
    - Add activity timeline to user profiles
        - With the activity of my contacts on mine
        - With the activity of the user on others
    - Add user contacts to user profile
    - Add project list to user profile
- Backlog panel
    - Improve the drag & drop behavior of USs in backlog panel
    - Select multiple US with `shift` in the backlog panel
- Global searches:
    - Show the reference of entities in search results (thanks to [@artlepool](https://github.com/artlepool))
    - Autofocus on search modal
- i18n.
  - Add deutsch (de) translation.
  - Add nederlands (nl) translation.

### Misc
- Improve performance: remove some unnecessary calls to the api.
- Lots of small and not so small bugfixes.


## 1.7.0 Empetrum Nigrum (2015-05-21)

### Features
- Make Taiga translatable (i18n support).
- i18n.
  - Add spanish (es) translation.
  - Add french (fr) translation.
  - Add finish (fi) translation.
  - Add catalan (ca) translation.
  - Add traditional chinese (zh-Hant) translation.
- Add Jitsi to our supported videoconference apps list

### Misc
- New contrib plugin for letschat (by Δndrea Stagi)
- Lots of small and not so small bugfixes.


## 1.6.0 Abies Bifolia (2015-03-17)

### Features
- Added custom fields per project for user stories, tasks and issues.
- Add to the Admin Panel the export to CSV sections.
- Reorganized the Admin Panel.

### Misc
- New contrib plugin for hipchat (by Δndrea Stagi)
- Plugin based authentication.
- Added Taiga Style Guide in support Pages to enhance open source design.
- Lots of small and not so small bugfixes.

## 1.5.0 Betula Pendula - FOSDEM 2015 (2015-01-29)

### Features
- Taiga webhooks
  + Created admin panel with webhook settings.
- Not showing closed milestones by default in backlog view.
- In kanban view an archived user story status doesn't show his content by default.
- Now you can export and import projects between Taiga instances.
- Improving performance.
- Email redesign.
- Support for contrib plugins (existing yet: slack, hall and gogs).

### Misc
- Lots of small and not so small bugfixes.


## 1.4.0 Abies veitchii (2014-12-10)

### Features
- Gitlab integration:
  + Create Admin Panel with the Gitlab webhooks settings.
- Bitbucket integration:
  + Create Admin Panel with the Bitbucket webhooks settings.
- Added team members section.
  + Exit a project feature.
- Taskboard enhancements: Collapse of columns (task statuses) and rows (user stories).
- Use enter to submit lightboxes forms.
- Improved concurrent edition to avoid double edition.

### Misc
- Upgrade to AngularJS 1.3.
- Lots of small and not so small bugfixes.


## 1.3.0 Dryas hookeriana (2014-11-18)

### Features
- GitHub integration (Phase I):
  + Add button to login/singin with a GitHub account.
  + Create Admin Panel with the GitHub webhooks settings.
- Show/Hide columns in the Kanban view.
- Differentiate blocked user stories on a milestone.

### Misc
- Lots of small and not so small bugfixes.


## 1.2.0 Picea obovata (2014-11-04)

### Features
- US/Task/Issue visualization and edition refactor. Now only one view for both.
- Multiple User stories Drag & Drop in the backlog.
- Add visual difference to closed USs in backlog panel.
- Show created date of attachments in the hover of the filename.
- Show info about maximun size allowed for avatar and attachments files.
- Add beta ribbon.
- Support for custom text when inviting users.

### Misc
- TAIGA loves Movember! The logo has a beautiful mustache this month.
- Lots of small and not so small bugfixes.


## 1.1.0 Alnus maximowiczii (2014-10-13)

### Features
- Promote an issue to a user story.
- Changed configuration format from coffeescript file to json.
- Add builtin analytics support.

### Misc
- Fix bug related to stange behavior of browser autofill and angularjs on login page.
- Fix bug on userstories ordering on sprints.
- Fix bug of projects list visualization on project nav on first page loading.


## 1.0.0 (2014-10-07)

### Features
- Redesign for taskboard and backlog summaries
- Allow feedback for users from the platform
- Real time changes for backlog, taskboard, kanban and issues

### Misc
- Lots of small and not so small bugfixes
