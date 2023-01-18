require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController
  def create
    build_resource(sign_up_params)
    if resource.valid?
      super
      @activity = ActivityLog.new(:activity => 'register', :result => 'ok', :payload => resource.email)
      @activity.save
    else
      @activity = ActivityLog.new(:activity => 'register', :result => 'error', :payload => resource.errors.full_messages)
      @activity.save
      render :new
    end
  end
end
