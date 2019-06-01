# frozen_string_literal: true

# name: discourse-pushover-notifications
# about: Plugin for integrating pushover notifications
# version: 0.1.0
# authors: Jeff Wong
# url: https://github.com/featheredtoast/discourse-pushover-notifications

enabled_site_setting :pushover_notifications_enabled

after_initialize do
  module ::DiscoursePushoverNotifications
    PLUGIN_NAME ||= 'discourse_pushover_notifications'.freeze

    autoload :Pusher, "#{Rails.root}/plugins/discourse-pushover-notifications/services/discourse_pushover_notifications/pusher"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscoursePushoverNotifications
    end
  end

  User.register_custom_field_type(DiscoursePushoverNotifications::PLUGIN_NAME, :json)
  whitelist_staff_user_custom_field DiscoursePushoverNotifications::PLUGIN_NAME

  DiscoursePushoverNotifications::Engine.routes.draw do
    post '/subscribe' => 'push#subscribe'
    post '/unsubscribe' => 'push#unsubscribe'
  end

  Discourse::Application.routes.append do
    mount ::DiscoursePushoverNotifications::Engine, at: '/pushover_notifications'
  end

  require_dependency 'application_controller'
  class DiscoursePushoverNotifications::PushController < ::ApplicationController
    requires_plugin DiscoursePushoverNotifications::PLUGIN_NAME

    layout false
    before_action :ensure_logged_in
    skip_before_action :preload_json

    def subscribe
      DiscoursePushoverNotifications::Pusher.subscribe(current_user, push_params)
      if DiscoursePushoverNotifications::Pusher.confirm_subscribe(current_user)
        render json: success_json
      else
        render json: { failed: 'FAILED', error: I18n.t("discourse_pushover_notifications.subscribe_error") }
      end
    end

    def unsubscribe
      DiscoursePushoverNotifications::Pusher.unsubscribe(current_user)
      render json: success_json
    end

    private

    def push_params
      params.require(:subscription)
    end
  end

  DiscourseEvent.on(:post_notification_alert) do |user, payload|
    if SiteSetting.pushover_notifications_enabled?
      Jobs.enqueue(:send_pushover_notifications, user_id: user.id, payload: payload)
    end
  end

  DiscourseEvent.on(:user_logged_out) do |user|
    if SiteSetting.pushover_notifications_enabled?
      DiscoursePushoverNotifications::Pusher.unsubscribe(user)
      user.save_custom_fields(true)
    end
  end

  require_dependency 'jobs/base'
  module ::Jobs
    class SendPushoverNotifications < Jobs::Base
      def execute(args)
        return unless SiteSetting.pushover_notifications_enabled?

        user = User.find(args[:user_id])
        DiscoursePushoverNotifications::Pusher.push(user, args[:payload])
      end
    end
  end
end
