class Admin::Wizards::BaseController < Admin::BaseController
  layout "wizard"

  helper_method :namespace

  private

    def namespace
      "admin"
    end
end
