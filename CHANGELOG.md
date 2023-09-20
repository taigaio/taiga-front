# Changelog

## 6.7.2 (unreleased)

- ...

## 6.7.1 (2023-09-20)

- Fix, relative wiki links.
- Fix, remove editor ellipsis transformation.
- Fix, wysiwyg autlinks.
- Fix, internal project urls open in the same tab.

## 6.7.0 (2023-06-12)

- Fix style for error messages in auth forms (thanks to [@DPRIYATHAM](https://github.com/DPRIYATHAM))

## 6.6.2 (2023-04-25)

- Fix error with attachment images linked in different wiki pages.

## 6.6.1 (2023-04-12)

- Improve the reconnection system of the events service.

## 6.6.0 (2023-03-06)

- Upgrade to node 16.19.1
- Update base image for docker

## 6.5.2 (2022-09-26)

- Updated links to the Taiga community site.
- Update locales

## 6.5.1 (2022-01-27)

- Enhance text collapse on long text by not dividing words.
- reorder data display in collapsed columns.

## 6.5.0 (2022-01-24)

- fix: prevent wrong text in collapsed columns in kanban for vertical languages (by @twovillage)
- fix: prevent overflowing long texts in layouts. (by @RyoNkmr)

## 6.4.3 (2021-10-27)

- fix: prevent taskboard column flicker after drag & drop
- Update locales

## 6.4.2 (2021-09-16)

- Update locales
- fix: error in editor with ">" and "<" chars
- fix: taskboard not collapsing as expected


## 6.4.1 (2021-09-08)

- fix: prevent store only_ref on project params local storage

## 6.4.0 (2021-09-06)

- feat: serve Taiga in subpath
- fix: fix actions showing on folded cards
- fix: fix non-assigned avatar not showing
- fix: redirect to previous url after login
- fix: neighbors performance

## 6.3.3 (2021-08-16)

- fix: remove auth credentials after logout and error.

## 6.3.2 (2021-08-12)

- fix: prevent redirect loop when the user is auth, token invalid & no refersh token

## 6.3.1 (2021-08-12)

- fix: move us between sprints
- feat: serve Taiga in subpath

## 6.3.0 (2021-08-10)

- fix: use pointerenter instead of mouseenter (by @astagi)
- feat: add US position selector in creation form
- feat: new Auth module, refresh auth token on api calls fail (history #tg-4625, issue #tgg-626))
- fix: prevent load archived status on filter
- fix: improve kanban performance

## 6.2.2 (2021-07-15)

- fix: prevent unnecessary kanban refresh with taiga-events
- fix: empty multiple assigned_to in kanban
- feat: Add multi language selector for text parts in editor
- feat: Add text alinment button in editor toolbar
- feat: Add todo list button in editor toolbar

## 6.2.1 (2021-06-22)

- fix: english as a fallback language
- fix: remove social media auto embed
- fix: backlog move to top

## 6.2.0 (2021-06-09)

- fix: richtext styles in custom fields
- fix: fix multiple backlog drag and drop issues
- fix: Userstory navigation within swimlanes
- fix: issues table order issues by ID instead of alphabetically
- Update promote to user story icon
- Move card options, assign, edit a delete card to a menu.
- Fix: Remove redundant copys on project default values settings.
- Fix: Hide milestone data and cut fetch in public issues if private sprints

## 6.1.1 (2021-05-18)

- Add support to checklists in markdown editor

## 6.1.0 (2021-05-04)

- Fix: allow sanitized HTML in detail page title
- Update github templates
- Plaintext with monospace font family

## 6.0.10 (2021-04-13)

- Feature: Add a "move to top" option to the context menu of the backlog ([#2239](https://github.com/kaleidos-ventures/taiga-front/pull/2239))
- Fix: Add simple line breaks to wysiwyg editor
- Update translations

## 6.0.9 (2021-04-06)

- Fix: prevent invalid query params on filters
- Fix: support more languages in the html editor
- Fix: kanban search race condition
- Layout adjustments on discover page
- Fix: Support flex gap for webkit browsers
- Fix: Clean and repair settings icon for webkit browser
- Fix: empty cards in kanban with swimlanes after toggle swimlane visibility

## 6.0.8 (2021-03-16)

- Fix: Change html lang attribute when the lenguage is not en
- Fix: epic screen on screen inferior to 1200px

## 6.0.7 (2021-03-09)

- General improvements to interface.
- Persist show/hide tags preferences on local storage

## 6.0.6 (2021-03-01)

- General improvements to interface.
- Fix: Can't create empty custom filters anymore.
- Fix: Can't save filters with the same name as an existing filter.
- Fix: Remove highlightjs default theme
- Fix: Wrong filter us count in empty backlog
- Fix: Highlight code when the user doesn't have edit permissions
- Improve kanban render performance
- Fix: Display warning in admin if reached max memberships in a project
- Display issues tags in sprint taskboard
- Fix: Fix incorrect count on filter

## 6.0.5 (2021-02-22)

- Added translation to Dansk
- Added translation to Serbian
- Added translation to Vietnamese
- General improvements to interface.
- Fix: Add new buttons and style to transfer owner, imports warnings lightbox and warnings on new projects
- Fix: User mention with underscore
- Fix: Drag and drop on empty backlog
- Feat: Editor, image with links

## 6.0.4 (2021-02-15)

### Misc

- Minor bug fix.
- Improve configuration for docker


## 6.0.3 (2021-02-07)

### Misc

- Debug mode now is disabled by default
- Minor bug fix.

## 6.0.0 (2021-02-02)

### Features

- Swimlanes

- Generate docker image

- Major UI changes

### Misc

- Improved performance in Kanban

## 5.5.10 (2021-01-04)

### Fix

- Fix comments style.

## 5.5.9 (2020-12-21)

### Features

- Render custom fields and block reason as Markdown.

### Fix

- Fix attachment refresh feature.

- Fix welcome email template layout.

### Misc

- Several minor changes.

### i18n

- Add Arabic.

- Update Russian.

## 5.5.8 (2020-11-11)

### Misc

- Fix error when zendesk is not loaded.

## 5.5.7 (2020-11-11) [YANKED]

### i18n

- Update Japanese and Italian translations.

### Misc

- Add Zendesk for integrated support.

## 5.5.6 (2020-10-07)

### Misc

- Improve userpilot integration.

- Fix typo.

## 5.5.5 (2020-09-16)

### Misc

- Minor bug fix.

## 5.5.4 (2020-09-08)

### Misc

- Several fixes.

### i18n

- Update French translation.

## 5.5.3 (2020-09-02)

### Misc

- Fix CSS bug with WYSIWYG toolbar.

## 5.5.0 (2020-08-19)

### Features

- Verify user email.

- Task promotion creates user story and deletes original task.

### Misc

- Upgraded node, gulp and other development dependencies.

- Several minor bugfixes.

## 5.0.15 (2020-08-07)

### Features

- Added integration with userpilot.

### Misc

- Fixed redirect after change email confirmation.

### i18n

- Updated translations (fa and fr).

## 5.0.13 (2020-06-08)

### i18n

- Updated translations (pt-br).

## 5.0.12 (2020-05-12)

### Misc

- Fixed several minor bugs.

### i18n

- Updated translations (pl).

## 5.0.11 (2020-05-04)

### Misc

- Fixed several minor bugs.

### i18n

- Updated translations (de, pl, ru, tr, uk).

## 5.0.10 (2020-03-12)

### Misc

- Fixed CSS bug.

## 5.0.9 (2020-03-11)

### Misc

- Fixed several minor bugs.

### i18n

- Updated lots of strings and updated their translations. Finally, oompa loompas have been substituted by the Taiga.

## 5.0.8 (2020-02-17)

### i18n

- Update Latvian translation.

### Misc

- Add Google tag manager integration.

## 5.0.7 (2020-02-06)

### i18n

- Update Korean translation.
- Add Latvian translation.

### Misc

- Several minor bugfixes.

## 5.0.6 (2020-01-15)

### Features

- Refresh default theme.

### Misc

- Several minor bugfixes.

## 5.0.5 (2020-01-08)

### Features

- Set login form visibility based on instance configuration.

- Promote task and issues to user story with watchers, attachments and comments.

### Misc

- Several minor bugfixes.

## 5.0.4 (2019-12-04)

- Fix translation problem with pluralization.

## 5.0.3 (2019-12-02)

- Fix several minor CSS bugs.

## 5.0.2 (2019-11-21)

- Update search counters on backlog when an US is moved.

- Fix several minor CSS bugs.

## 5.0.1 (2019-11-15)

- Fix CSS issue.

## 5.0.0 (2019-11-13)

- BREAKING CHANGE Big refactor of base CSS for themes that can break custom themes.

- Change comment box position based on comments order.

- Refresh attachment URL on markdown fields to support protected backend.

- Fixed drag&drop of attachments to text fields.

- Redesign detail header.

## 4.2.14 (2019-10-01)

- Disabled malfunctioning notification infinite scroll.
- Updated translations. Big improvement in Italian coverage (grazie mille!).
- Several minor fixes.

## 4.2.13 (2019-08-06)

- Minor fixes

## 4.2.12 (2019-08-06)

- Add Taiga Fresh theme.
- Minor fixes.

## 4.2.11 (2019-07-24)

- Progressive Kanban render.
- Minor fixes.

## 4.2.10 (2019-07-11)

- Close loader before kanban/backlog filter request.

## 4.2.8 (2019-07-03)

- Fix multiple assign US button

## 4.2.7 (2019-06-24)

- Assign roles as watchers
- Minor bug fixes

## 4.2.6 (2019-06-12)

- Vote button redesign
- Minor bug fixes

## 4.2.5 (2019-05-09)
- Revet remove bluebird dependency

## 4.2.4 (2019-05-09)

- Fix moment local for Chinese
- Multiple minor fixes
- Remove bluebird dependency

## 4.2.3 (2019-04-16)

- Enable hiding list items on Dashboard
- Minor fixes.

## 4.2.3 (2019-03-21)

## 4.2.1 (2019-03-20)

- Add user stories dashboard filter
- Change Kanban zoom level
- Filter history by entry type
- Minor fixes.

## 4.2.0 (2019-02-28)

- Promote Tasks to US
- Display US status on Taskboard
- Add closed user stories filter in epics dashboard
- Activate Hebrew and Basque languages
- Minor fixes.

## 4.1.1 (2019-02-04)

- Pin npm Flot dependence

## 4.1.0 (2019-02-04)

### Misc

- Minor fixes

### Features

- Negative filters
- Activate Ukrainian language

## 4.0.4 (2019-01-15)

### Misc

- Minor bug fixes.

## 4.0.3 (2018-12-11)

### Misc

- Update locales.
- Remove tips
- Minor bug fixes.

## 4.0.2 (2018-12-04)

### Misc

- Update locales.
- Minor bug fixes.

## 4.0.0 Larix cajanderi (2018-11-28)

### Features

- Custom home section (https://tree.taiga.io/project/taiga/issue/3059)
- Custom fields (https://tree.taiga.io/project/taiga/issue/3725):
    - Dropdown
    - Checkbox
    - Number
- Bulk move unfinished objects in sprint (https://tree.taiga.io/project/taiga/issue/5451)
- Paginate history activity
- Improve notifications area (https://tree.taiga.io/project/taiga/issue/2165 and
  https://tree.taiga.io/project/taiga/issue/3752)

### Misc

- Minor icon changes
- Lots of small bug fixes

## 3.4.6 (2018-10-30)

### Misc

- Update subscriptions messages

## 3.4.5 (2018-10-15)

### Misc

- Security bug fixes
- Minor bug fixes.

## 3.4.4 (2018-09-19)

### Misc

- Minor bug fixes.

## 3.4.3 (2018-09-19)

### Misc

- Allow reorder tasks in US (https://tree.taiga.io/project/taiga/issue/5479)
- Minor bug fixes.

## 3.4.2 (2018-08-27)

### Misc

- Fix pickadate conflicts
- Modify meeting module URL checking
- Minor bug fixes.

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
