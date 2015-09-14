var utils = require('../utils');
var helper = module.exports;

helper.assignToLightbox = function() {
    let el = $('div[tg-lb-assignedto]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        selectFirst: function() {
            el.$$('div[data-user-id]').first().click();
        },
        getName: function(item) {
            return el.$$('div[data-user-id]').get(item).$('.watcher-name').getText();
        }
    };

    return obj;
};
