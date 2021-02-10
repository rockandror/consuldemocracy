class Admin::ModeratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @moderators = @moderators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:moderator)
                 .page(params[:page])
                 .for_render
  end

  def create
    @moderator.user_id = params[:user_id]
    @moderator.save

    redirect_to admin_moderators_path
  end

  def destroy  
    if !@moderator.blank?
      if !current_user.blank? && current_user.id == @moderator.user_id
        flash[:error] = I18n.t("admin.moderators.moderator.restricted_removal")
      else
        user = User.find(@moderator.user_id)
        user.profiles_id = nil
        user.save
        @moderator.destroy
      end
    else
      flash[:error] = I18n.t("admin.moderators.moderator.restricted_removal")
    end

    redirect_to admin_moderators_path
  rescue
    flash[:error] = I18n.t("admin.moderators.moderator.restricted_removal")
    redirect_to admin_moderators_path
  end
  end
end
