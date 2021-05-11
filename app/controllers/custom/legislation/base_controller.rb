class Legislation::BaseController < ApplicationController
  include FeatureFlags

  before_action :authenticate_user!

  feature_flag :legislation

  def legislation_proposal_votes(proposals)
    @legislation_proposal_votes = current_user ? current_user.legislation_proposal_votes(proposals) : {}
  end
end
