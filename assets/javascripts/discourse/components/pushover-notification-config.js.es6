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

  @computed
  pushoverNotificationSubscribed() {
    return (
      Discourse.User.current().custom_fields.discourse_pushover_notifications !=
      null
    );
  },

  actions: {
    subscribe() {
      subscribePushoverNotification(this.get("subscription"));
    },

    unsubscribe() {
      unsubscribePushoverNotification();
    }
  }
});
