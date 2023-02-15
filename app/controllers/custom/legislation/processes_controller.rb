require_dependency Rails.root.join("app", "controllers", "legislation", "processes_controller").to_s

class Legislation::ProcessesController
  include CommentableActions
  helper_method :resource_model, :resource_name

  alias_method :consul_index, :index

  def index
    consul_index

    @tag = params[:search]
    @processes = @processes.tagged_with(@tag) if @tag
    @processes = @processes.per(5)
  end

  private

    def resource_model
      Legislation::Process
    end
end
