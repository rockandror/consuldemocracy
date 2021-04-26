class Admin::SectionAdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @section_administrators = @section_administrators.page(params[:page])
  end

  def destroy
    begin
      @section_administrator = SectionAdministrator.find(params[:id])
      if !@section_administrator.blank?
        if !current_user.blank? && current_user.id == @section_administrator.user_id
          flash[:error] = I18n.t("admin.section_administrators.section_administrator.restricted_removal")
        else
          user = User.find(@section_administrator.user_id)
          user.profiles_id = nil
          user.save
          @section_administrator.destroy
        end
      else
        flash[:error] = I18n.t("admin.section_administrators.section_administrator.restricted_removal")
      end

      redirect_to admin_section_administrators_path
    rescue
      flash[:error] = I18n.t("admin.section_administrators.section_administrator.restricted_removal")
      redirect_to admin_section_administrators_path
    end
  end
end
