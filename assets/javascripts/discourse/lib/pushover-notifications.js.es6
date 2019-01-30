import { ajax } from "discourse/lib/ajax";

export function subscribe(subscription) {
  ajax("/pushover_notifications/subscribe", {
    type: "POST",
    data: { subscription: subscription }
  }).then(() => {
    console.log("yae");
    Discourse.User.current().custom_fields.discourse_pushover_notifications = subscription;
  });
}

export function unsubscribe() {
  ajax("/pushover_notifications/unsubscribe", {
    type: "POST"
  }).then(() => {
    console.log("nae");
    Discourse.User.current().custom_fields.discourse_pushover_notifications = null;
  });
}
