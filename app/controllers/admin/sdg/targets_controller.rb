class Admin::SDG::TargetsController < Admin::BaseController
  Target = ::SDG::Target

  def index
    @targets = Target.all
  end
end
