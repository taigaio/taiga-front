var utils = require('../utils');

var helper = module.exports;

helper.openCreateProjectPage = function() {
    $$('.create-project-btn').get(1).click();
};

helper.createProject = function() {
    let obj = {
        el: function() {
            return $('.e2e-create-project-selector');
        },
        openDuplicateWizard: function() {
            return $('.e2e-duplicate-project').click();
        },
        selectProjectToDuplicate: function() {
            return $('.e2e-duplicate-project-reference option').get(1).click();
        },
        duplicateProject: function() {
            return $('.e2e-create-project-action-duplicate').click();
        }

    };

    return obj;
}

// helper.createProjectLightbox = function() {
//     let obj = {
//         el: function() {
//             return $('div[tg-lb-create-project]');
//         },
//         waitOpen: function() {
//             return utils.lightbox.open(obj.el());
//         },
//         waitClose: function() {
//             return utils.lightbox.close(obj.el());
//         },
//         next: async function() {
//             $('.wizard-step.active .button-green').click();
//
//             await browser.sleep(1000);
//         },
//         submit: function() {
//             return $('div[tg-lb-create-project]  .button-green').click();
//         },
//         name: function() {
//             return $$('div[tg-lb-create-project] input[type="text"]').get(0);
//         },
//         description: function() {
//             return $('div[tg-lb-create-project] textarea');
//         },
//         errors: function() {
//             return $$('.checksley-error-list li');
//         }
//     };
//
//     return obj;
// };

helper.delete = async function() {
    $('.delete-project').click();

    let lb = $('div[tg-lb-delete-project]');

    await utils.lightbox.open(lb);

    return lb.$('.button-green').click();
};
