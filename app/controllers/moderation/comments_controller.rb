class Moderation::CommentsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{all pending_flag_review with_ignored_flag with_confirmed_hide_at}, only: :index
  has_orders %w{flags newest}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def resource_model
      Comment
    end

    def author_id
      :user_id
    end
end
