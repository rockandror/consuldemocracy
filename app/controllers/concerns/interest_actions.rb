module InterestActions
  extend ActiveSupport::Concern

  def follow
    Interest.follow(current_user, interestable)
    respond_with interestable, template: "#{controller_name}/_refresh_interest_actions"
  end

  def unfollow
    Interest.unfollow(current_user, interestable)
    respond_with interestable, template: "#{controller_name}/_refresh_interest_actions"
  end

  private

    def interestable
      instance_variable_get("@#{resource_model.to_s.downcase}")
    end

end
