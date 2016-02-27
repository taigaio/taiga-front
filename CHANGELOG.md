# Changelog #


## 2.0.0 ??? (unreleased)

### Features
- Ability to create url custom fields. (thanks to [@astagi](https://github.com/astagi)).
- Moved from iconfont to SVG sprite icon system and redesign.
- Add Sprint title on search results for User Stories

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
