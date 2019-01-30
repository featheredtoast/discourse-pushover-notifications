import { default as computed } from "ember-addons/ember-computed-decorators";

import {
  subscribe as subscribePushoverNotification,
  unsubscribe as unsubscribePushNotification
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

  @computed("pushoverNotificationSubscribed")
  instructions(pushoverNotificationSubscribed) {
    if (pushoverNotificationSubscribed) {
      return I18n.t("discourse_pushover_notifications.disable_note");
    } else {
      return I18n.t("discourse_pushover_notifications.enable_note");
    }
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
