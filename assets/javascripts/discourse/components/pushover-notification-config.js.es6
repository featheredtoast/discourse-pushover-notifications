import { default as computed } from "ember-addons/ember-computed-decorators";

import {
  subscribe as subscribePushoverNotification,
  unsubscribe as unsubscribePushoverNotification
} from "discourse/plugins/discourse-pushover-notifications/discourse/lib/pushover-notifications";

export default Ember.Component.extend({
  @computed
  showPushoverNotification() {
    return this.siteSettings.pushover_notifications_enabled;
  },

  disabled: Ember.computed.empty("subscription"),

  calculateSubscribed() {
    this.set(
      "pushoverNotificationSubscribed",
      Discourse.User.current().custom_fields.discourse_pushover_notifications !=
        null
    );
  },

  pushoverNotificationSubscribed: null,

  init() {
    this._super(...arguments);
    this.set(
      "pushoverNotificationSubscribed",
      Discourse.User.current().custom_fields.discourse_pushover_notifications !=
        null
    );
  },

  actions: {
    subscribe() {
      subscribePushoverNotification(this.subscription).then(() => {
        Discourse.User.current().custom_fields.discourse_pushover_notifications = this.subscription;
        this.calculateSubscribed();
      });
    },

    unsubscribe() {
      unsubscribePushoverNotification().then(() => {
        Discourse.User.current().custom_fields.discourse_pushover_notifications = null;
        this.calculateSubscribed();
      });
    }
  }
});
