class Admin::SiteCustomization::MemberTypesController < Admin::SiteCustomization::BaseController

  # GET /admin/site_customization/member_types
  def index
    @member_types = ::MemberType.all
  end

  # POST /admin/site_customization/member_types
  def create

    if (params["new_value"].is_a? String) && !params["new_value"].empty?

      @admin_site_customization_member_type = ::MemberType.new(:value => params["new_value"])
      if @admin_site_customization_member_type.save
        redirect_to admin_site_customization_member_types_url, notice: t('admin.member_types.member_type.index.creation_ok')
      else
        render :index
      end
    else
      redirect_to admin_site_customization_member_types_url, alert: t('admin.member_types.member_type.index.creation_ko')
    end
  end

  # PATCH/PUT /admin/site_customization/member_types/1
  def update
    set_admin_site_customization_member_type

    if @admin_site_customization_member_type.fixed?
      if @admin_site_customization_member_type.update(:url_ws => params["url_ws"])
        redirect_to admin_site_customization_member_types_url, notice: t('admin.member_types.member_type.index.updated')
      end
    else
      if @admin_site_customization_member_type.update(:value => params["value"], :url_ws => params["url_ws"])
        redirect_to admin_site_customization_member_types_url, notice: t('admin.member_types.member_type.index.updated')
      end
    end
  end

  # DELETE /admin/site_customization/member_types/1
  def destroy

    set_admin_site_customization_member_type

    if @admin_site_customization_member_type.fixed?
      redirect_to admin_site_customization_member_types_url, alert: t('admin.member_types.member_type.index.destroy_error')
    else
      @admin_site_customization_member_type.destroy
      redirect_to admin_site_customization_member_types_url, notice: t('admin.member_types.member_type.index.destroyed')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_site_customization_member_type
      @admin_site_customization_member_type = ::MemberType.find(params[:id])
    end
end
