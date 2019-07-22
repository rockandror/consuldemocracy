class Verification::Handlers::Response
  attr_reader :message, :submitted_data, :submitted_data, :response_data, :success
  alias :success? :success

  def initialize(success, message, submitted_data = {}, response_data = {})
    @success = success
    @message = message
    @submitted_data = submitted_data
    @response_data = response_data
  end
end