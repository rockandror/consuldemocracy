class Admin::SuresAdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @sures_administrators = SuresAdministrator.all.page(params[:page])
  end

  def destroy
    begin
      if !@sures_administrator.blank?
        if !current_user.blank? && current_user.id == @sures_administrator.user_id
          flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
        else
          user = User.find(@sures_administrator.user_id).profiles_id = nil
          user.save
          @sures_administrator.destroy
        end
      else
        flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
      end

      redirect_to admin_sures_administrators_path
    rescue
      flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
      redirect_to admin_sures_administrators_path
    end
  end
end
