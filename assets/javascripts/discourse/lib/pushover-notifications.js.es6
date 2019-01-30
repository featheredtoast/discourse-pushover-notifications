import { ajax } from "discourse/lib/ajax";

export function subscribe(subscription) {
  ajax("/pushover_notifications/subscribe", {
    type: "POST",
    data: { subscription: subscription }
  });
}

export function unsubscribe() {
  ajax("/pushover_notifications/unsubscribe", {
    type: "POST"
  });
}
