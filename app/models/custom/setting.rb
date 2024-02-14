require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    # Change this code when you'd like to add settings that aren't
    # already present in the database. These settings will be added when
    # first installing CONSUL DEMOCRACY, when deploying code with Capistrano,
    # or when manually executing the `settings:add_new_settings` task.
    #
    # If a setting already exists in the database, changing its value in
    # this file will have no effect unless the task `rake db:seed` is
    # invoked or the method `Setting.reset_defaults` is executed. Doing
    # so will overwrite the values of all existing settings in the
    # database, so use with care.
    #
    # The tests in the spec/ folder rely on CONSUL DEMOCRACY's default
    # settings, so it's recommended not to change the default settings
    # in the test environment.
    def defaults
      if Rails.env.test?
        consul_defaults.merge({
          "feature.cookies_consent": false,
          "cookies_consent.more_info_link": "",
          "cookies_consent.setup_page": false,
          "cookies_consent.version_name": "v1",
          "cookies_consent.admin_test_mode": false
        })
      else
        consul_defaults.merge({
          "feature.cookies_consent": false,
          "facebook_handle": "CabildoTenerife",
          "instagram_handle": "cabildotenerife/?hl=es",
          "twitter_handle": "CabildoTenerife",
          "youtube_handle": "channel/UCSnQFzldpaeR5D7zTOp3pRA?view_as=subscriber",
          "cookies_consent.more_info_link": "",
          "cookies_consent.setup_page": false,
          "cookies_consent.version_name": "v1",
          "cookies_consent.admin_test_mode": false
        })
      end
    end
  end
end
