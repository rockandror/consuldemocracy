# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: Rails.application.secrets.password_config,
                       password_confirmation: Rails.application.secrets.password_config, confirmed_at: Time.current,
                       terms_of_service: "1")
  admin.create_administrator
end

Setting.reset_defaults

# Default custom pages
load Rails.root.join("db", "pages.rb")
