require "net/https"

module DiscoursePushNotifications
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
        url: payload[:post_url],
        token: SiteSetting.pushover_api_key,
        user: user.custom_fields[DiscoursePushNotifications::PLUGIN_NAME]
      }

      url = URI.parse("https://api.pushover.net/1/messages.json")
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(message)
      res = Net::HTTP.new(url.host, url.port)
      res.use_ssl = true
      res.verify_mode = OpenSSL::SSL::VERIFY_PEER
      res.start { |http| http.request(req) }
    end

    def self.clear_subscriptions(user)
      user.custom_fields.delete(DiscoursePushNotifications::PLUGIN_NAME)
    end

    def self.subscribe(user, subscription)
      user.custom_fields[DiscoursePushNotifications::PLUGIN_NAME] = subscription
      user.save_custom_fields(true)
    end

    def self.unsubscribe(user, subscription)
      user.custom_fields.delete(DiscoursePushNotifications::PLUGIN_NAME)
      user.save_custom_fields(true)
    end

    protected

    def self.extract_unique_id(subscription)
      subscription
    end
  end
end
