class SDGManagement::TargetsController < SDGManagement::BaseController
  Target = ::SDG::Target

  load_and_authorize_resource class: "SDG::Target", only: [:index]

  def index
    @targets = Target.all.sort
  end
end
