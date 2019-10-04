class Admin::WizardsController < Admin::BaseController
  def index
    @wizards = ["installation", "verification"].freeze
  end
end
