module AccessDeniedHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.html do
          if current_user && current_user.officing_voter?
            redirect_to new_officing_session_path
          else
            redirect_to main_app.root_url, alert: exception.message
          end
        end

        format.json do
          render json: { error: exception.message }, status: :forbidden
        end
      end
    end
  end
end
