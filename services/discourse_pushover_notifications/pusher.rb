# frozen_string_literal: true

require "net/https"

module DiscoursePushoverNotifications
  class Pusher
    def self.push(user, payload)
      message = {
        title: I18n.t(
          "discourse_pushover_notifications.popup.#{Notification.types[payload[:notification_type]]}",
          site_title: SiteSetting.title,
          topic: payload[:topic_title],
          username: payload[:username]
        ),
        message: payload[:excerpt],
        url: "#{Discourse.base_url}/#{payload[:post_url]}",
        token: SiteSetting.pushover_notifications_api_key,
        user: user.custom_fields[DiscoursePushoverNotifications::PLUGIN_NAME]
      }
      self.pushover(user, message)
    end

    def self.confirm_subscribe(user)
      message = {
        title: I18n.t(
          "discourse_pushover_notifications.confirm_title",
          site_title: SiteSetting.title,
        ),
        message: I18n.t("discourse_pushover_notifications.confirm_body"),
        url: "#{Discourse.base_url}",
        token: SiteSetting.pushover_notifications_api_key,
        user: user.custom_fields[DiscoursePushoverNotifications::PLUGIN_NAME]
      }
      self.pushover(user, message)
    end

    def self.subscribe(user, subscription)
      user.custom_fields[DiscoursePushoverNotifications::PLUGIN_NAME] = subscription
      user.save_custom_fields(true)
    end

    def self.unsubscribe(user)
      user.custom_fields.delete(DiscoursePushoverNotifications::PLUGIN_NAME)
      user.save_custom_fields(true)
    end

    private

    def self.pushover(user, message)
      url = URI.parse("https://api.pushover.net/1/messages.json")
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(message)
      res = Net::HTTP.new(url.host, url.port)
      res.use_ssl = true
      res.verify_mode = OpenSSL::SSL::VERIFY_PEER
      response = res.start do |http|
        response = http.request(req)
      end
      if response.code.to_i != 200
        self.unsubscribe user
        return false
      end
      return true
    end
  end
end
