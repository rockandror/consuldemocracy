require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController
  before_action :authenticate_user!
end
