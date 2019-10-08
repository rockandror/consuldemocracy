class Admin::Wizards::VerificationController < Admin::Wizards::BaseController
  def new
    @settings = [Setting.find_by(key: "feature.custom_verification_process"),
                 Setting.find_by(key: "feature.user.skip_verification"),
                 Setting.find_by(key: "feature.remote_census")]
  end

  def finish
    @fields = ::Verification::Field.all.order(:position)
  end
end
