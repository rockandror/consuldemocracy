class Admin::OrganizationsController < Admin::BaseController
  has_filters %w{pending all verified rejected}, only: :index

  load_and_authorize_resource except: :search

  def index
    @organizations = @organizations.send(@current_filter)
    @organizations = @organizations.includes(:user)
                                   .order("users.created_at", :name, "users.email")
                                   .page(params[:page])
  end

  def search
    @organizations = Organization.includes(:user)
                                 .search(params[:term])
                                 .order("users.created_at", :name, "users.email")
                                 .page(params[:page])
  end

  def verify
    @organization.verify
    redirect_to admin_organizations_path(params_strong)
  end

  def reject
    @organization.reject
    redirect_to admin_organizations_path(params_strong)
  end
  private
    def params_strong
      params.permit(:filter)
    end

end
