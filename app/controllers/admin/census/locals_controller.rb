class Admin::Census::LocalsController < Admin::BaseController
  load_and_authorize_resource class: "Census::Local"

  def index
    @locals = @locals.search(params[:search])
    @locals = @locals.page(params[:page])
  end

  def create
    @local = Census::Local.new(local_params)
    if @local.save
      redirect_to admin_census_locals_path,
        notice: t("admin.census.locals.create.notice")
    else
      render :new
    end
  end

  def update
    if @local.update(local_params)
      redirect_to admin_census_locals_path,
        notice: t("admin.census.locals.update.notice")
    else
      render :edit
    end
  end

  private

    def local_params
      attributes = [:document_type, :document_number, :date_of_birth, :postal_code]
      params.require(:census_local).permit(*attributes)
    end
end
