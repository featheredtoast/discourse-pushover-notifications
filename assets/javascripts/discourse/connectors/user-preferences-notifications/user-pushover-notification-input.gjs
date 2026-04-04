import Component from "@glimmer/component";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { i18n } from "discourse-i18n";
import {
  subscribe as subscribePushoverNotification,
  unsubscribe as unsubscribePushoverNotification,
} from "discourse/plugins/discourse-pushover-notifications/discourse/lib/pushover-notifications";

export default class UserPushoverNotificationInput extends Component {
  @service currentUser;
  @service siteSettings;
  @tracked loading = false;
  @tracked errorMessage;
  @tracked subscription = "";
  @tracked subscribed = this.currentUser.custom_fields.discourse_pushover_notifications != null;

  get showPushoverNotification() {
    return this.siteSettings.pushover_notifications_enabled;
  }

  get disabled() {
    if(this.subscription?.length === 0 || this.loading) {
      return true;
    }
    return false;
  }
  @action
  subscribe() {
    this.loading = true;
    this.errorMessage = null;
    subscribePushoverNotification(this.subscription)
      .then((response) => {
        if (response.success) {
          this.subscribed = true;
        } else {
          this.errorMessage = response.error;
        }
      })
      .finally(() => this.loading = false);
  }
  @action
  unsubscribe() {
    this.loading = true;
    this.errorMessage = null;
    unsubscribePushoverNotification()
      .then((response) => {
        if (response.success) {
          this.subscribed = false;
        } else {
          this.errorMessage = response.error;
        }
      })
      .finally(() => this.loading = false);
  }
  <template>
    {{#if this.showPushoverNotification}}
      <div class="control-group pushover-notifications">
        <label class="control-label">{{i18n
            "discourse_pushover_notifications.title"
          }}</label>
        {{#if this.errorMessage}}
          <div class="alert alert-error">{{this.errorMessage}}</div>
        {{/if}}
        <div class="controls">
          <div>
            {{#if this.subscribed}}
              <DButton
                @icon="bell-slash"
                @label="discourse_pushover_notifications.disable"
                @action={{this.unsubscribe}}
                @disabled={{this.loading}}
              />
              <ConditionalLoadingSpinner @size="small" @condition={{this.loading}}/>
            {{else}}
              <Input
                @type="text"
                @placeholder={{i18n
                  "discourse_pushover_notifications.api_key_placeholder"
                }}
                @value={{this.subscription}}
                disabled={{this.loading}}
              />
              <DButton
                @icon="bell"
                @label="discourse_pushover_notifications.enable"
                @action={{this.subscribe}}
                @disabled={{this.disabled}}
              />
              <ConditionalLoadingSpinner @size="small" @condition={{this.loading}}/>
              <div class="instructions">{{{i18n
                  "discourse_pushover_notifications.instructions"
                }}}</div>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
