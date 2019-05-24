class Admin::Census::LocalsController < Admin::BaseController
  load_and_authorize_resource class: "Census::Local"

  def index
    @locals = @locals.search(params[:search])
    @locals = @locals.page(params[:page])
  end
end
