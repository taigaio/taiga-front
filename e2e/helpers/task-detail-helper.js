var utils = require('../utils');

var helper = module.exports;

helper.iocaine = function() {
    let el = $('tg-task-is-iocaine-button fieldset');

    let obj = {
        el: el,

        togleIocaineStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isIocaine: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};
