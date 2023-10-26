class Admin::Poll::ResultsController < Admin::Poll::BaseController
  before_action :load_poll

  def index
    questions = @poll.questions
    answers = Poll::Answer.where(question: questions)

    respond_to do |format|
      format.csv do
        send_data Poll::Exporter.new(answers).to_csv,
                  filename: "answers.csv"
      end
      format.html
    end
    
    @partial_results = @poll.partial_results
  end

  private

    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end
end
