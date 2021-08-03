require_dependency Rails.root.join("app", "controllers", "legislation", "base_controller").to_s

class Legislation::BaseController
  before_action :authenticate_user!
end
