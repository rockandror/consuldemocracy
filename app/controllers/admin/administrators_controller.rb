class Admin::AdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @administrators = @administrators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:administrator)
                 .page(params[:page])
                 .for_render
  end

  def create
    @administrator.user_id = params[:user_id]
    @administrator.save

    redirect_to admin_administrators_path
  end

  def destroy
      if !@administrator.blank?
        if !current_user.blank? && current_user.id == @administrator.user_id
          flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
        else
          user = User.find(@administrator.user_id)
          user.profiles_id = nil
          user.save
          @administrator.destroy
        end
      else
        flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
      end

      redirect_to admin_administrators_path
  rescue
    flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
    redirect_to admin_administrators_path
  end
end
