class Admin::WizardsController < Admin::BaseController

  def index
    @wizards = ["installation"].freeze
  end

end
