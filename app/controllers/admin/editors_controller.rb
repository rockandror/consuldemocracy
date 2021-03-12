class Admin::EditorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @editors = Editor.all.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:editor)
                 .page(params[:page])
                 .for_render
  end

  def create
    @editor.user_id = params[:user_id]
    @editor.save

    redirect_to admin_editors_path
  end

  def destroy
    if !@editor.blank?
      if !current_user.blank? && current_user.id == @editor.user_id
        flash[:error] = I18n.t("admin.editors.editor.restricted_removal")
      else
        user = User.find(@editor.user_id)
        user.profiles_id = nil
        user.save
        @editor.destroy
      end
    else
      flash[:error] = I18n.t("admin.editors.editor.restricted_removal")
    end

    redirect_to admin_editors_path
  rescue
    flash[:error] = I18n.t("admin.editors.editor.restricted_removal")
    redirect_to admin_editors_path
  end
end
