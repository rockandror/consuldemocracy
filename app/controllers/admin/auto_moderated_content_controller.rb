class Admin::AutoModeratedContentController < Admin::BaseController
  VALID_FILTERS = %w[confirmed declined].freeze

  has_filters %w{all confirmed declined}, only: :index

  def index
    @moderated_comments = ::Comment.where(
      id: load_moderated_contents
    ).includes(:moderated_texts, :user)
  end

  private
    def load_moderated_contents
      if params[:filter].present? && is_valid_filter?
        ::ModeratedContent.send("#{params[:filter]}").pluck(:moderable_id)
      else
        ::ModeratedContent.all.pluck(:moderable_id)
      end
    end

    def is_valid_filter?
      VALID_FILTERS.include?(params[:filter])
    end
end
