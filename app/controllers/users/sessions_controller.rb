class Users::SessionsController < Devise::SessionsController

  def create
    logger.info("AUDIT") { "#{params[:user][:login]} is trying logging" }
    params[:ip] = request.remote_ip
    super
    logger.info("AUDIT") { "#{current_user.email} log in successful" }
  end


  def destroy
    logger.info("AUDIT") { "#{current_user.email} logging out" }
    super
  end

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

end
