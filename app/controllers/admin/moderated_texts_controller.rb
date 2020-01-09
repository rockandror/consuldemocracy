class Admin::ModeratedTextsController < Admin::BaseController

  def index
    @words = ModeratedText.all
  end

  def new
    @word = ModeratedText.new
  end

end
