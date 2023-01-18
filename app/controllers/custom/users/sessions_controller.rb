require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  after_action :log_failed_login, :only => :new

  # POST /resource/sign_in
  def create
    super
    @activity = ActivityLog.new(:activity => 'login', :result => 'ok', :payload => sign_in_params[:login])
    @activity.save
  end

  private
    def log_failed_login
      user = User.find_by(email: sign_in_params[:login])
      if failed_login?
        @activity = ActivityLog.new(:activity => 'login', :result => 'error', :payload => sign_in_params[:login])
        @activity.save
        if user && user.failed_attempts == Setting["login_attempts_before_lock"].to_i
          @activity = ActivityLog.new(:activity => 'login', :result => 'blocked', :payload => sign_in_params[:login])
          @activity.save
        end
      end
    end

    def failed_login?
      (options = request.env["warden.options"]) && options[:action] == "unauthenticated"
    end
end
