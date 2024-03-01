import { ajax } from "discourse/lib/ajax";

export function subscribe(subscription) {
  return ajax("/pushover_notifications/subscribe", {
    type: "POST",
    data: { subscription },
  });
}

export function unsubscribe() {
  return ajax("/pushover_notifications/unsubscribe", {
    type: "POST",
  });
}
