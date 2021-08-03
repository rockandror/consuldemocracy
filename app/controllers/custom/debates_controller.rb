require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController
  before_action :authenticate_user!
end
