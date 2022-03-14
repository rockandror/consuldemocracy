module GuestUsers
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  def current_user
    super || guest_user
  end

  def user_signed_in?
    current_user && !current_user.guest?
  end

  private

    def guest_user
      return @guest_user if @guest_user

      if session[:guest_user_id]
        @guest_user = User.find_by(username: session[:guest_user_id])
        @guest_user = nil unless @guest_user&.guest
      end
      @guest_user ||= begin
        guest_user = create_guest_user(session[:guest_user_id])
        session[:guest_user_id] = guest_user.username
        guest_user
      end
      @guest_user
    end

    def create_guest_user(key = nil)
      authentication_key = guest_username_authentication_key(key)
      User.new do |user|
        user.username = authentication_key
        user.email = "#{authentication_key}@example.com"
        user.guest = true
        user.current_sign_in_at = Time.current
        user.skip_confirmation!
        user.save!(validate: false)
      end
    end

    def guest_username_authentication_key(key = nil)
      key || "guest_#{guest_user_unique_suffix}"
    end

    def guest_user_unique_suffix
      SecureRandom.uuid
    end
end
