class Admin::ConsultantsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @consultants = Consultant.all.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:consultant)
                 .page(params[:page])
                 .for_render
  end

  def create
    @consultant.user_id = params[:user_id]
    @consultant.save

    redirect_to admin_consultants_path
  end

  def destroy
    begin
      if !@consultant.blank?
        if !current_user.blank? && current_user.id == @consultant.user_id
          flash[:error] = I18n.t("admin.consultants.consultant.restricted_removal")
        else
          user = User.find(@consultant.user_id).profiles_id = nil
          user.save
          @consultant.destroy
        end
      else
        flash[:error] = I18n.t("admin.consultants.consultant.restricted_removal")
      end

      redirect_to admin_consultants_path
    rescue
      flash[:error] = I18n.t("admin.consultants.consultant.restricted_removal")
      redirect_to admin_consultants_path
    end
  end
end
