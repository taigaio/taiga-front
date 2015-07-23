var utils = require('../utils');

var helper = module.exports;

helper.assignedTo = function() {
  let el = $('.assigned-to');

  let obj = {
      el: el,
      clear: async function() {
        el.$('.icon-delete').click();
        await utils.lightbox.confirm.ok();
        await browser.waitForAngular();
      },

      assign: function() {
        el.$('.user-assigned').click();
      },

      getUserName: function() {
        return el.$('.user-assigned').getText();
      }

  };

  return obj;
};

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
        }

    };

    return obj;
};
