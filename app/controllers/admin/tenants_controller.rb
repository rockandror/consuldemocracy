class Admin::TenantsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @tenants = @tenants.order(:name)
  end

  def new
  end

  def edit
  end

  def create
    if @tenant.save
      update_default_tenant_administrator
      redirect_to admin_tenants_path, notice: t("admin.tenants.create.notice")
    else
      render :new
    end
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to admin_tenants_path, notice: t("admin.tenants.update.notice")
    else
      render :edit
    end
  end

  private

    def tenant_params
      params.require(:tenant).permit(:name, :schema, :schema_type)
    end

    def update_default_tenant_administrator
      Tenant.switch(@tenant.schema) do
        default_admin_account = User.administrators.first
        default_admin_account.update!(email: current_user.email,
                                      username: current_user.username,
                                      encrypted_password: current_user.encrypted_password)
      end
    end
end
