require_dependency Rails.root.join("app", "controllers", "legislation", "processes_controller").to_s

class Legislation::ProcessesController
  before_action :authenticate_user!
end
