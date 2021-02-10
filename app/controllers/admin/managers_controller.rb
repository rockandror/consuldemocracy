class Admin::ManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @managers = @managers.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:manager)
                 .page(params[:page])
                 .for_render
  end

  def create
    @manager.user_id = params[:user_id]
    @manager.save

    redirect_to admin_managers_path
  end

  def destroy   
    if !@manager.blank?
      if !current_user.blank? && current_user.id == @manager.user_id
        flash[:error] = I18n.t("admin.managers.manager.restricted_removal")
      else
        user = User.find(@manager.user_id)
        user.profiles_id = nil
        user.save
        @manager.destroy
      end
    else
      flash[:error] = I18n.t("admin.managers.manager.restricted_removal")
    end

    redirect_to admin_managers_path
  rescue
    flash[:error] = I18n.t("admin.managers.manager.restricted_removal")
    redirect_to admin_managers_path
  end
end
