class Admin::HiddenBudgetInvestmentsController < Admin::BaseController
  include FeatureFlags

  has_filters %w{all with_confirmed_hide without_confirmed_hide}, only: :index

  feature_flag :budgets

  before_action :load_investment, only: [:confirm_hide, :restore]

  def index
    @investments = Budget::Investment.only_hidden.send(@current_filter)
                                                 .order(hidden_at: :desc)
                                                 .page(params[:page])
  end

  def confirm_hide
    @investment.confirm_hide
    redirect_to admin_hidden_budget_investments_path(params_strong)
  end

  def restore
    @investment.restore
    @investment.ignore_flag
    Activity.log(current_user, :restore, @investment)
    redirect_to admin_hidden_budget_investments_path(params_strong)
  end

  private

    def params_strong
      params.permit(:filter)
    end

    def load_investment
      @investment = Budget::Investment.with_hidden.find(params[:id])
    end

end
