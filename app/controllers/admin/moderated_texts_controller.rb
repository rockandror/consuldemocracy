class Admin::ModeratedTextsController < Admin::BaseController

  def index
    @words = ModeratedText.all
  end

end
