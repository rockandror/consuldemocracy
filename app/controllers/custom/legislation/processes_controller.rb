require_dependency Rails.root.join("app", "controllers", "legislation", "processes_controller").to_s

class Legislation::ProcessesController
  include CommentableActions

  helper_method :resource_model, :resource_name

  def index
    puts 'PARAMS!'
    puts params[:search]
    @tag = nil

    @current_filter ||= "open"
    @processes = ::Legislation::Process.send(@current_filter).published
                 .not_in_draft.order(start_date: :desc)
    if params[:search]
      @tag = params[:search]
      @processes = @processes.tagged_with(@tag)
    end
    @processes = Kaminari.paginate_array(@processes).page(params[:page]).per(5)
  end

  private

    def resource_model
      Legislation::Process
    end
end
