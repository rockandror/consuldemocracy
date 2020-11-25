class SDGManagement::GoalsController < SDGManagement::BaseController

  load_and_authorize_resource class: "SDG::Goal", only: [:index]

  def index
    @goals = SDG::Goal.order(:code)
  end
end
