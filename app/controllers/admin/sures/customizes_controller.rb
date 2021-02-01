class Admin::Sures::CustomizesController < Admin::BaseController
  respond_to :html, :js

  def index
    load_header
    load_cards
  end

  private

  def load_header
    @header = ::Sures::CustomizeCard.header
  end

  def load_cards
    @cards = ::Sures::CustomizeCard.body
  end
end