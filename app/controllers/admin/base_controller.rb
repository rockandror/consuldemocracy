class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :double_verified
  skip_authorization_check
  before_action :verify_administrator

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end

    def double_verified
      raise CanCan::AccessDenied unless current_user.double_verification?
    end

end
