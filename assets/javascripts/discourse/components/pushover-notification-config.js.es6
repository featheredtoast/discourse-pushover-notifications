import { default as discourseComputed } from "discourse-common/utils/decorators";


import {
  subscribe as subscribePushoverNotification,
  unsubscribe as unsubscribePushoverNotification
} from "discourse/plugins/discourse-pushover-notifications/discourse/lib/pushover-notifications";

export default Ember.Component.extend({
  @discourseComputed
  showPushoverNotification() {
    return this.siteSettings.pushover_notifications_enabled;
  },

  has_subscription: Ember.computed.empty("subscription"),
  disabled: Ember.computed.or("has_subscription", "loading"),
  loading: false,
  errorMessage: null,

  calculateSubscribed() {
    this.set(
      "pushoverNotificationSubscribed",
      this.currentUser.custom_fields.discourse_pushover_notifications !=
        null
    );
  },

  pushoverNotificationSubscribed: null,

  init() {
    this._super(...arguments);
    this.setProperties({
      pushoverNotificationSubscribed:
        this.currentUser.custom_fields
          .discourse_pushover_notifications != null,
      errorMessage: null
    });
  },

  actions: {
    subscribe() {
      this.setProperties({
        loading: true,
        errorMessage: null
      });
      subscribePushoverNotification(this.subscription)
        .then(response => {
          if (response.success) {
            this.currentUser.custom_fields.discourse_pushover_notifications = this.subscription;
            this.calculateSubscribed();
          } else {
            this.set("errorMessage", response.error);
          }
        })
        .finally(() => this.set("loading", false));
    },

    unsubscribe() {
      this.setProperties({
        loading: true,
        errorMessage: null
      });
      unsubscribePushoverNotification()
        .then(response => {
          if (response.success) {
            this.currentUser.custom_fields.discourse_pushover_notifications = null;
            this.calculateSubscribed();
          } else {
            this.set("errorMessage", response.error);
          }
        })
        .finally(() => this.set("loading", false));
    }
  }
});
