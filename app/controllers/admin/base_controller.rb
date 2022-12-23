class Admin::BaseController < ApplicationController
  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_administrator

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user&.administrator?
    end

    def set_layout
      multitenancy_management_mode? ? "multitenancy" : "admin"
    end
end
