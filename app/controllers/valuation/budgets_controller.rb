class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budgets = @budgets.published.open.order(created_at: :desc)
  end
end
