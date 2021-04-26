class Admin::SuperadministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @super_administrators = Superadministrator.all.page(params[:page])
  end

  def destroy
    begin
      @super_administrator = Superadministrator.find(params[:id])
      if !@super_administrator.blank?
        if !current_user.blank? && current_user.id == @super_administrator.user_id
          flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
        else
          user = User.find(@super_administrator.user_id)
          user.profiles_id = nil
          user.save
          @super_administrator.destroy
        end
      else
        flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
      end

      redirect_to admin_superadministrators_path
    rescue
      flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
      redirect_to admin_superadministrators_path
    end
  end
end
