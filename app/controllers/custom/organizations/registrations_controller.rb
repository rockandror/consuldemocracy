require_dependency Rails.root.join("app", "controllers", "organizations", "registrations_controller").to_s

class Organizations::RegistrationsController
  include Recaptchable

  def self.invisible_captcha_actions
    _process_action_callbacks.select do |callback|
      callback.raw_filter.inspect.include?("invisible_captcha")
    end.map(&:filter)
  end

  skip_before_action(*invisible_captcha_actions)
  prepend_before_action :check_captcha, only: [:create]
end
