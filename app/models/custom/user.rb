require_dependency Rails.root.join("app/models/user").to_s

class User
  attr_accessor :first_name
  attr_accessor :last_name

  def postpone_email_change?
    false
  end

  def send_oauth_confirmation_instructions
    update(oauth_email: nil) if oauth_email.present?
  end

  def build_username
    default_username = [
      first_name.downcase.strip.gsub(" ", "_"),
      last_name.downcase.strip.gsub(" ", "_")
    ].reject(&:empty?).join("_")

    for n in 1..Float::INFINITY
      new_username = "#{default_username}#{n if n > 1}"

      return new_username unless self.class.where(username: new_username).select { |user| user != self }.any?
    end
  end

  class << self
    alias_method :consul_first_or_initialize_for_oauth, :first_or_initialize_for_oauth

    def first_or_initialize_for_oauth(auth)
      user = consul_first_or_initialize_for_oauth(auth)

      user.tap do
        if user.new_record?
          user.confirmed_at = DateTime.current
          user.registering_with_oauth = true
        end
      end
    end
  end
end
