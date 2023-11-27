class InstallationController < ApplicationController
  skip_authorization_check

  def details
    respond_to do |format|
      format.any { render json: consul_installation_details.to_json, content_type: "application/json" }
    end
  end

  private

    def consul_installation_details
      { release: "2.0.1" }.merge(features: settings_feature_flags)
    end

    def settings_feature_flags
      Setting.by_group(:processes)
             .pluck(:key, :value)
             .to_h
             .transform_keys { |key| key.remove("process.") }
    end
end
