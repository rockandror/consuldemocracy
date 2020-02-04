class Admin::AutoModeratedContentController < Admin::BaseController
  before_action :load_content, only: [:show_again]

  VALID_FILTERS = %w[confirmed declined].freeze
  has_filters %w{all confirmed declined}, only: :index

  def index
    @moderated_comments = ::Comment.where(
      id: load_moderated_contents
    ).includes(:moderated_texts, :user)
  end

  def show_again
    @content.update_attribute(:declined_at, Time.current)
    redirect_to admin_auto_moderated_content_index_path
  end

  private
    def load_moderated_contents
      if params[:filter].present? && is_valid_filter?
        ::ModeratedContent.send("#{params[:filter]}").pluck(:moderable_id)
      else
        ::ModeratedContent.all.pluck(:moderable_id)
      end
    end

    def load_content
      @content = ::ModeratedContent.find_by(
        moderable_id: params[:auto_moderated_content_id],
        moderable_type: 'Comment'
      )
    end

    def is_valid_filter?
      VALID_FILTERS.include?(params[:filter])
    end
end
