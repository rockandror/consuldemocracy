class Admin::Verification::Residents::BaseController < Admin::Verification::BaseController
  helper_method :namespace

  private

    def namespace
      "admin"
    end

end
