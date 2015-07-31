var utils = require('../utils');

var helper = module.exports;

helper.teamRequirement = function() {
    let el = $('tg-us-team-requirement-button');

    let obj = {
        el: el,

        toggleStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isRequired: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};

helper.clientRequirement = function() {
    let el = $('tg-us-client-requirement-button');

    let obj = {
        el: el,

        toggleStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isRequired: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};
