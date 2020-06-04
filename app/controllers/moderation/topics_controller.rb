class Moderation::TopicsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{no_flags with_confirmed_hide_at}, only: :index
  has_orders %w{newest}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def resource_model
      Topic
    end

    def author_id
      :author_id
    end
end
